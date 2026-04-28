import SwiftUI
import SwiftData
import UserNotifications
import Network

protocol CloudSyncing {
    func push(_ envelope: CloudSyncEnvelope) throws
}

struct LocalCloudSyncDraftService: CloudSyncing {
    func push(_ envelope: CloudSyncEnvelope) throws {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("CloudSync", isDirectory: true)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = directory.appendingPathComponent("firestore-sync-draft.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(envelope)
        try data.write(to: url, options: .atomic)
    }
}

@MainActor
final class AppViewModel: ObservableObject {
    private enum StorageKeys {
        static let appState = "mandalart-sync.app-state"
        static let lastNotifiedGapSignature = "mandalart-sync.last-notified-gap-signature"
    }

    private enum SecretKeys {
        static let service = "mandalart-sync.credentials"
        static let githubToken = "github.personal-access-token"
        static let googleCalendarToken = "google-calendar.access-token"
    }

    private let gitHubService: GitHubCommitFetching
    private let googleCalendarService: GoogleCalendarFetching
    private let cloudSyncService: CloudSyncing
    private let modelContext: ModelContext
    private var isPersistingState = false
    private let networkMonitor = NetworkMonitor()

    @Published var mainGoal: String {
        didSet { persistState() }
    }
    @Published var categories: [MandalartCategory] {
        didSet { persistState() }
    }
    @Published var journalEntries: [JournalEntry] {
        didSet { persistState() }
    }
    @Published var gapInsights: [CognitiveGapInsight] {
        didSet { persistState() }
    }
    @Published var githubSettings: GitHubSettings {
        didSet { persistState() }
    }
    @Published var googleCalendarSettings: GoogleCalendarSettings {
        didSet { persistState() }
    }
    @Published var notificationsEnabled: Bool {
        didSet { persistState() }
    }
    @Published var isSyncing = false
    @Published var syncErrorMessage: String?
    @Published var syncRequiresSettings = false
    @Published var isOffline = false
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var lastCloudSyncAt: Date? {
        didSet { persistState() }
    }
    @Published var cloudSyncStatusMessage: String = "未同期" {
        didSet { persistState() }
    }
    @Published var activeDemoPreset: DemoScenarioPreset?

    /// 目標未設定＝初回起動（オンボーディング表示判定に使用）
    var isFirstLaunch: Bool { mainGoal.isEmpty }

    static func makeModelContainer(isStoredInMemoryOnly: Bool = false) -> ModelContainer {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
            return try ModelContainer(
                for: StoredCategory.self,
                StoredBlock.self,
                StoredJournalEntry.self,
                StoredGapInsight.self,
                StoredSettings.self,
                configurations: configuration
            )
        } catch {
            fatalError("SwiftData container creation failed: \(error)")
        }
    }

    convenience init(
        gitHubService: GitHubCommitFetching = GitHubService(),
        googleCalendarService: GoogleCalendarFetching = GoogleCalendarService(),
        cloudSyncService: CloudSyncing = LocalCloudSyncDraftService()
    ) {
        let container = Self.makeModelContainer(isStoredInMemoryOnly: true)
        self.init(
            modelContext: container.mainContext,
            gitHubService: gitHubService,
            googleCalendarService: googleCalendarService,
            cloudSyncService: cloudSyncService
        )
    }

    init(
        modelContext: ModelContext,
        gitHubService: GitHubCommitFetching = GitHubService(),
        googleCalendarService: GoogleCalendarFetching = GoogleCalendarService(),
        cloudSyncService: CloudSyncing = LocalCloudSyncDraftService()
    ) {
        self.modelContext = modelContext
        self.gitHubService = gitHubService
        self.googleCalendarService = googleCalendarService
        self.cloudSyncService = cloudSyncService
        let state = Self.loadPersistedState(modelContext: modelContext) ?? Self.loadPersistedState()
        self.mainGoal = state.mainGoal
        self.categories = state.categories
        self.journalEntries = state.journalEntries.sorted { $0.date > $1.date }
        self.gapInsights = state.gapInsights.sorted { $0.score > $1.score }
        self.githubSettings = state.githubSettings
        self.googleCalendarSettings = state.googleCalendarSettings
        self.notificationsEnabled = state.notificationsEnabled
        let storedSettings = Self.loadStoredSettings(modelContext: modelContext)
        self.lastCloudSyncAt = storedSettings?.lastCloudSyncAt
        self.cloudSyncStatusMessage = storedSettings?.cloudSyncStatusMessage ?? "未同期"
        persistState()
        networkMonitor.onStatusChange = { [weak self] offline in
            self?.isOffline = offline
        }
        networkMonitor.start()
    }

    var weeklyProgress: Double {
        let blocks = categories.flatMap(\.blocks)
        guard !blocks.isEmpty else { return 0 }
        let total = blocks.reduce(0) { $0 + $1.progress }
        return total / Double(blocks.count)
    }

    var allDailyTasks: [DailyTask] {
        categories.flatMap { category in
            category.blocks.map { block in
                DailyTask(
                    id: block.id,
                    title: block.title,
                    blockId: block.id,
                    categoryId: category.id,
                    category: category.title,
                    theme: category.color,
                    targetGoal: mainGoal
                )
            }
        }
    }

    var todayAnsweredBlockIDs: Set<Int> {
        Set(todayCheckinEntries.compactMap(\.relatedBlockId))
    }

    var pendingDailyTasks: [DailyTask] {
        allDailyTasks.filter { !todayAnsweredBlockIDs.contains($0.blockId) }
    }

    var todayCheckinEntries: [JournalEntry] {
        journalEntries
            .filter { entry in
                Calendar.current.isDateInToday(entry.date)
                && (entry.kind == .manualCompleted || entry.kind == .manualSkipped)
            }
            .sorted { $0.date > $1.date }
    }

    var todayCompletedCount: Int {
        todayCheckinEntries.filter { $0.kind == .manualCompleted }.count
    }

    var totalTaskCount: Int {
        allDailyTasks.count
    }

    var todayCompletionRate: Int {
        guard totalTaskCount > 0 else { return 0 }
        return Int((Double(todayCompletedCount) / Double(totalTaskCount) * 100).rounded())
    }

    var cognitiveGapScore: Int {
        let relevant = gapInsights.filter { $0.severity != .aligned }
        guard !relevant.isEmpty else { return 0 }
        let total = relevant.prefix(5).reduce(0) { $0 + $1.score }
        return Int((Double(total) / Double(min(relevant.count, 5))).rounded())
    }

    var topGapInsights: [CognitiveGapInsight] {
        Array(gapInsights.prefix(3))
    }

    var mostCriticalGap: CognitiveGapInsight? {
        gapInsights.first { $0.severity.rank >= CognitiveGapSeverity.warning.rank }
    }

    var hasGitHubToken: Bool {
        !(storedGitHubToken()?.isEmpty ?? true)
    }

    var hasGoogleCalendarToken: Bool {
        !(storedGoogleCalendarAccessToken()?.isEmpty ?? true)
    }


    var demoScenarioSteps: [DemoScenarioStep] {
        switch activeDemoPreset {
        case .cognitiveGap:
            return [
                DemoScenarioStep(id: "gap-1", title: "1. ホームを開く", detail: "目標『ハッカソンで優勝する』と全体の進捗を確認する。"),
                DemoScenarioStep(id: "gap-2", title: "2. 「目標」タブでマンダラートを確認する", detail: "32項目のアクションを開き、GitHubキーワードが未設定のブロックをタップしてキーワードを追加する。"),
                DemoScenarioStep(id: "gap-3", title: "3. 「結果」タブで分析を確認する", detail: "GitHub連携分析を開き、コミットが取得されたアクションと未記録のアクションの差を見せる。"),
                DemoScenarioStep(id: "gap-4", title: "4. 「行動ログ」でタイムラインを見る", detail: "GitHubコミットと手動記録が混在したタイムラインを確認する。")
            ]
        case .alignedMomentum:
            return [
                DemoScenarioStep(id: "aligned-1", title: "1. ホームを開く", detail: "目標と進捗を確認する。同期ボタンを押してGitHubコミットを取得する。"),
                DemoScenarioStep(id: "aligned-2", title: "2. 「行動ログ」でタイムラインを見る", detail: "GitHubコミット、カレンダー予定、手動記録が並んでいるタイムラインを確認する。"),
                DemoScenarioStep(id: "aligned-3", title: "3. 「結果」タブで分析を確認する", detail: "GitHub連携分析でコミットが全アクションに対応している状態を見せる。")
            ]
        case .apiError:
            return [
                DemoScenarioStep(id: "error-1", title: "1. 同期ボタンを押す", detail: "ホーム右上の同期ボタンを押す。エラーアラートが表示される。"),
                DemoScenarioStep(id: "error-2", title: "2. エラー内容を確認する", detail: "401/403の認証エラーの場合、「設定を開く」ボタンが表示される。"),
                DemoScenarioStep(id: "error-3", title: "3. 設定から復帰する", detail: "設定画面でGitHubトークンを再設定し、同期を再実行する。")
            ]
        case nil:
            return []
        }
    }

    func prepareApp() async {
        await refreshNotificationAuthorizationStatus()
        if notificationsEnabled {
            await requestNotificationPermissionIfNeeded()
        }
        analyzeCognitiveGaps()
    }

    /// 同期が必要な設定（GitHub username）が揃っているか
    var hasSyncTarget: Bool {
        !githubSettings.owner.isEmpty
    }

    func updateCategoryTitle(categoryId: Int, title: String) {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        categories[index].title = title
    }

    func updateBlockTitle(categoryId: Int, blockId: Int, title: String) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard let blockIndex = categories[categoryIndex].blocks.firstIndex(where: { $0.id == blockId }) else { return }
        categories[categoryIndex].blocks[blockIndex].title = title
    }

    func clearBlock(categoryId: Int, blockId: Int) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard let blockIndex = categories[categoryIndex].blocks.firstIndex(where: { $0.id == blockId }) else { return }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            categories[categoryIndex].blocks[blockIndex].cleared = true
            categories[categoryIndex].blocks[blockIndex].progress = 100
            categories[categoryIndex].blocks[blockIndex].resonance = 100
        }
    }

    func recordCheckin(task: DailyTask, answer: CheckinAnswer) {
        removeTodayEntry(for: task.blockId)

        if answer == .completed {
            applyCompletionProgress(categoryId: task.categoryId, blockId: task.blockId)
        }

        let entry = JournalEntry(
            id: "manual-\(task.blockId)-\(Int(Date().timeIntervalSince1970))",
            date: Date(),
            kind: answer == .completed ? .manualCompleted : .manualSkipped,
            source: "Manual",
            systemImageName: answer == .completed ? "checkmark.circle.fill" : "pause.circle.fill",
            iconHex: answer == .completed ? "22c55e" : "f59e0b",
            action: answer == .completed ? "アクションを完了しました" : "今日は見送りました",
            detail: task.title,
            targetGoal: task.targetGoal,
            relatedBlockId: task.blockId
        )

        journalEntries.insert(entry, at: 0)
        analyzeCognitiveGaps()
    }

    func replaceEntries(of kind: JournalEntryKind, with entries: [JournalEntry]) {
        journalEntries.removeAll { $0.kind == kind }
        journalEntries.append(contentsOf: entries)
        journalEntries.sort { $0.date > $1.date }
    }

    func appendSystemEntry(action: String, detail: String, targetGoal: String = "全般") {
        let entry = JournalEntry(
            id: "system-\(UUID().uuidString)",
            date: Date(),
            kind: .system,
            source: "System",
            systemImageName: "star.fill",
            iconHex: "fbbf24",
            action: action,
            detail: detail,
            targetGoal: targetGoal,
            relatedBlockId: nil
        )
        journalEntries.insert(entry, at: 0)
    }

    func storedGitHubToken() -> String? {
        KeychainStore.read(service: SecretKeys.service, account: SecretKeys.githubToken)
    }

    func storedGoogleCalendarAccessToken() -> String? {
        KeychainStore.read(service: SecretKeys.service, account: SecretKeys.googleCalendarToken)
    }

    func updateGitHubSettings(owner: String, repository: String = "", token: String) {
        githubSettings.owner = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        githubSettings.repository = repository.trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedToken.isEmpty {
            KeychainStore.delete(service: SecretKeys.service, account: SecretKeys.githubToken)
            githubSettings.hasPersonalAccessToken = false
        } else {
            KeychainStore.save(trimmedToken, service: SecretKeys.service, account: SecretKeys.githubToken)
            githubSettings.hasPersonalAccessToken = true
        }
    }

    func updateGoogleCalendarSettings(calendarId: String, accessToken: String) {
        googleCalendarSettings.calendarId = calendarId.trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedToken = accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedToken.isEmpty {
            KeychainStore.delete(service: SecretKeys.service, account: SecretKeys.googleCalendarToken)
            googleCalendarSettings.hasAccessToken = false
        } else {
            KeychainStore.save(trimmedToken, service: SecretKeys.service, account: SecretKeys.googleCalendarToken)
            googleCalendarSettings.hasAccessToken = true
        }
    }

    func updateNotificationsEnabled(to enabled: Bool) {
        notificationsEnabled = enabled
        if enabled {
            Task {
                await requestNotificationPermissionIfNeeded()
                analyzeCognitiveGaps()
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cognitive-gap-feedback"])
        }
    }



    func applyDemoPreset(_ preset: DemoScenarioPreset) {
        activeDemoPreset = preset

        switch preset {
        case .cognitiveGap:
            mainGoal = "技育CAMPで優勝する"
            categories = Self.makeDemoCategories()
            journalEntries = Self.makeCognitiveGapJournalEntries(mainGoal: mainGoal)
            gapInsights = []
            syncErrorMessage = nil
            lastCloudSyncAt = Date()
            cloudSyncStatusMessage = "ギャップシナリオを適用中"
            notificationsEnabled = true
            analyzeCognitiveGaps(referenceDate: Self.demoReferenceDate)

        case .alignedMomentum:
            mainGoal = "技育CAMPで優勝する"
            categories = Self.makeDemoCategories(aligned: true)
            journalEntries = Self.makeAlignedJournalEntries(mainGoal: mainGoal)
            gapInsights = []
            syncErrorMessage = nil
            lastCloudSyncAt = Date()
            cloudSyncStatusMessage = "同期済みシナリオを適用中"
            notificationsEnabled = true
            analyzeCognitiveGaps(referenceDate: Self.demoReferenceDate)

        case .apiError:
            mainGoal = "技育CAMPで優勝する"
            categories = Self.makeDemoCategories()
            journalEntries = Self.makeCognitiveGapJournalEntries(mainGoal: mainGoal)
            gapInsights = []
            syncErrorMessage = "GitHub のトークンが無効です（401）。設定からトークンを再設定してください。"
            syncRequiresSettings = true
            lastCloudSyncAt = nil
            cloudSyncStatusMessage = "APIエラーシナリオを適用中"
            notificationsEnabled = true
            analyzeCognitiveGaps(referenceDate: Self.demoReferenceDate)
        }
    }

    func resetDemoPreset() {
        activeDemoPreset = nil
        resetAllData()
    }

    func resetAllData() {
        let state = PersistedAppState.default
        mainGoal = state.mainGoal
        categories = state.categories
        journalEntries = state.journalEntries
        gapInsights = state.gapInsights
        githubSettings = state.githubSettings
        googleCalendarSettings = state.googleCalendarSettings
        notificationsEnabled = state.notificationsEnabled
        lastCloudSyncAt = nil
        cloudSyncStatusMessage = "未同期"
        KeychainStore.delete(service: SecretKeys.service, account: SecretKeys.githubToken)
        KeychainStore.delete(service: SecretKeys.service, account: SecretKeys.googleCalendarToken)
        UserDefaults.standard.removeObject(forKey: StorageKeys.lastNotifiedGapSignature)
        syncErrorMessage = nil
    }

    func triggerSync() {
        guard !isSyncing else { return }

        if isOffline {
            syncErrorMessage = "オフラインです。接続を確認してから再度お試しください。"
            return
        }

        isSyncing = true
        syncErrorMessage = nil
        syncRequiresSettings = false

        Task {
            await syncExternalServices()
        }
    }

    private func applyCompletionProgress(categoryId: Int, blockId: Int) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard let blockIndex = categories[categoryIndex].blocks.firstIndex(where: { $0.id == blockId }) else { return }

        let current = categories[categoryIndex].blocks[blockIndex]
        categories[categoryIndex].blocks[blockIndex].progress = min(100, current.progress + 12.5)
        categories[categoryIndex].blocks[blockIndex].resonance = min(100, current.resonance + 8)
        categories[categoryIndex].blocks[blockIndex].cleared = categories[categoryIndex].blocks[blockIndex].progress >= 100
    }

    private func removeTodayEntry(for blockId: Int) {
        journalEntries.removeAll { entry in
            entry.relatedBlockId == blockId
            && Calendar.current.isDateInToday(entry.date)
            && (entry.kind == .manualCompleted || entry.kind == .manualSkipped)
        }
    }

    private func syncExternalServices() async {
        defer { isSyncing = false }

        var summary: [String] = []
        var failures: [String] = []

        do {
            let commits = try await gitHubService.fetchCommits(
                username: githubSettings.owner,
                token: storedGitHubToken()
            )
            let entries = commits.map { commit in
                JournalEntry(
                    id: "github-\(commit.sha)",
                    date: commit.date,
                    kind: .githubCommit,
                    source: "GitHub: \(commit.repositoryName)",
                    systemImageName: "chevron.left.forwardslash.chevron.right",
                    iconHex: "18181b",
                    action: "コミットを取得しました",
                    detail: commit.message.components(separatedBy: .newlines).first ?? "Recent commit",
                    targetGoal: mainGoal,
                    relatedBlockId: nil
                )
            }
            replaceEntries(of: .githubCommit, with: entries)
            summary.append("GitHub \(entries.count)コミット")
        } catch let error as GitHubServiceError {
            failures.append(error.localizedDescription)
            if error.requiresTokenReset { syncRequiresSettings = true }
        } catch {
            failures.append(error.localizedDescription)
        }

        if let token = storedGoogleCalendarAccessToken(),
           !token.isEmpty,
           !googleCalendarSettings.calendarId.isEmpty {
            do {
                let events = try await googleCalendarService.fetchUpcomingEvents(
                    calendarId: googleCalendarSettings.calendarId,
                    accessToken: token
                )
                let entries = events.map { event in
                    JournalEntry(
                        id: "calendar-\(event.id)",
                        date: event.start.dateTime ?? Date(),
                        kind: .calendarEvent,
                        source: "Google Calendar",
                        systemImageName: "calendar",
                        iconHex: "2563eb",
                        action: "予定を取得しました",
                        detail: event.summary ?? "無題の予定",
                        targetGoal: mainGoal,
                        relatedBlockId: nil
                    )
                }
                replaceEntries(of: .calendarEvent, with: entries)
                summary.append("Google Calendar \(entries.count)件")
            } catch let error as GoogleCalendarServiceError {
                failures.append(error.localizedDescription)
                if error.requiresTokenReset { syncRequiresSettings = true }
            } catch {
                failures.append(error.localizedDescription)
            }
        } else {
            summary.append("Google Calendar 未設定")
        }

        if summary.isEmpty {
            syncRequiresSettings = true
            appendSystemEntry(
                action: "同期の設定が必要です",
                detail: "設定から GitHub / Google Calendar の連携先を入力してください。"
            )
        } else {
            appendSystemEntry(
                action: failures.isEmpty ? "同期が完了しました" : "一部の同期が完了しました",
                detail: summary.joined(separator: " / ")
            )
        }

        // 401/403 を含む場合は設定への誤導を優先
        if failures.isEmpty {
            syncErrorMessage = nil
            syncRequiresSettings = false
        } else if syncRequiresSettings {
            syncErrorMessage = failures.first
        } else {
            syncErrorMessage = failures.joined(separator: "\n")
        }

        if failures.isEmpty {
            lastCloudSyncAt = Date()
            cloudSyncStatusMessage = summary.joined(separator: " / ")
        } else {
            cloudSyncStatusMessage = failures.joined(separator: "\n")
        }

        analyzeCognitiveGaps()
    }

    private func analyzeCognitiveGaps(referenceDate: Date = .now) {
        // GitHubコミットのみを分析対象にする（Google Calendarは行動ログ表示のみ）
        let githubEntries = journalEntries.filter { entry in
            entry.kind == .githubCommit
            && entry.date >= Calendar.current.date(byAdding: .day, value: -7, to: referenceDate)!
        }

        let insights = allDailyTasks.compactMap { task -> CognitiveGapInsight? in
            let targetCommitCount = githubCommitTarget(for: task)
            let matchedCommits: [JournalEntry]

            if targetCommitCount != nil {
                let startOfToday = Calendar.current.startOfDay(for: referenceDate)
                matchedCommits = githubEntries.filter { entry in
                    entry.date >= startOfToday && entry.date <= referenceDate
                }
            } else {
                matchedCommits = githubEntries.filter { entry in
                    entryMatchesTask(entry, task: task)
                }
            }

            // GitHubコミットがなければ分析対象外
            guard !matchedCommits.isEmpty || targetCommitCount != nil else { return nil }

            let matchedSources = Array(Set(matchedCommits.map(\.source))).sorted()
            let target = targetCommitCount ?? 1
            let achieved = matchedCommits.count >= target
            let score = targetCommitCount == nil ? max(8, 20 - matchedCommits.count * 5) : (achieved ? 8 : 65)

            return CognitiveGapInsight(
                id: "gap-\(task.blockId)",
                generatedAt: referenceDate,
                blockId: task.blockId,
                blockTitle: task.title,
                categoryTitle: task.category,
                score: score,
                severity: achieved ? .aligned : .caution,
                selfReportedCompleted: false,
                matchedEvidenceCount: matchedCommits.count,
                matchedSources: matchedSources,
                summary: targetCommitCount == nil
                    ? "「\(task.title)」は GitHub に \(matchedCommits.count) 件のコミットが確認できます。"
                    : "今日のGitHubコミットは \(matchedCommits.count) / \(target) 件です。",
                recommendation: achieved
                    ? "行動が積み上がっています。このまま続けましょう。"
                    : "コミット数で自動計測しています。目標数に届いていなければ、作業を小さく切ってpushしましょう。"
            )
        }
        .sorted {
            if $0.score == $1.score {
                return $0.blockTitle < $1.blockTitle
            }
            return $0.score > $1.score
        }

        gapInsights = insights

        Task {
            await scheduleGapNotificationIfNeeded(referenceDate: referenceDate)
        }
    }

    private func entryMatchesTask(_ entry: JournalEntry, task: DailyTask) -> Bool {
        let haystack = normalize("\(entry.source) \(entry.action) \(entry.detail) \(entry.targetGoal)")
        return keywords(for: task).contains { keyword in
            keyword.count >= 2 && haystack.contains(keyword)
        }
    }

    private func githubCommitTarget(for task: DailyTask) -> Int? {
        let normalizedTitle = normalize(task.title)
        guard normalizedTitle.contains("コミット") || normalizedTitle.contains("commit") else {
            return nil
        }

        if let range = task.title.range(of: #"\d+"#, options: .regularExpression),
           let value = Int(task.title[range]) {
            return max(value, 1)
        }

        return 1
    }

    func updateBlockGitHubKeywords(categoryId: Int, blockId: Int, keywords: [String]) {
        guard let ci = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard let bi = categories[ci].blocks.firstIndex(where: { $0.id == blockId }) else { return }
        categories[ci].blocks[bi].githubKeywords = keywords
        analyzeCognitiveGaps()
    }

    private func keywords(for task: DailyTask) -> Set<String> {
        // ブロックにユーザー設定の GitHub キーワードがあればそれを優先使用
        let block = categories
            .flatMap(\.blocks)
            .first { $0.id == task.blockId }
        if let block = block, !block.githubKeywords.isEmpty {
            return Set(block.githubKeywords.map(normalize).filter { !$0.isEmpty })
        }

        let baseStrings = [task.title, task.category, mainGoal]
        var tokens = Set(baseStrings.map(normalize).filter { !$0.isEmpty })

        let synonymMap: [String: [String]] = [
            "コーディング": ["code", "coding", "swift", "ios", "app", "実装", "開発", "commit"],
            "OSS": ["oss", "pr", "pullrequest", "issue", "repo", "repository", "github", "commit"],
            "ブログ": ["blog", "qiita", "note", "article", "記事", "発信"],
            "Twitter": ["twitter", "tweet", "post", "x", "発信"],
            "筋トレ": ["gym", "workout", "training", "exercise", "筋トレ"],
            "ランニング": ["run", "running", "jog", "ランニング"],
            "睡眠": ["sleep", "rest", "睡眠"],
            "技術": ["swift", "ios", "code", "commit", "開発", "実装"],
            "発信": ["blog", "qiita", "note", "tweet", "post", "発信"],
            "健康": ["health", "workout", "sleep", "gym", "run", "筋トレ"],
            "マインド": ["mind", "reflection", "gratitude", "振り返り", "感謝"],
            "フィードバック": ["feedback", "review", "comment", "フィードバック"],
            "ミーティング": ["meeting", "1on1", "mtg", "ミーティング"]
        ]

        for source in baseStrings {
            for (key, values) in synonymMap where source.localizedCaseInsensitiveContains(key) {
                values.map(normalize).forEach { tokens.insert($0) }
            }
        }

        return tokens
    }

    private func normalize(_ string: String) -> String {
        string
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "[\\s\\p{P}\\p{S}]+", with: "", options: .regularExpression)
    }

    private func requestNotificationPermissionIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        }

        await refreshNotificationAuthorizationStatus()
    }

    private func refreshNotificationAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationAuthorizationStatus = settings.authorizationStatus
    }

    private func scheduleGapNotificationIfNeeded(referenceDate: Date) async {
        guard notificationsEnabled else { return }
        guard let insight = mostCriticalGap else { return }
        guard insight.severity.rank >= CognitiveGapSeverity.warning.rank else { return }

        await refreshNotificationAuthorizationStatus()
        guard notificationAuthorizationStatus == .authorized || notificationAuthorizationStatus == .provisional else {
            return
        }

        let signature = "\(insight.id)-\(dayIdentifier(from: referenceDate))-\(insight.score)"
        if UserDefaults.standard.string(forKey: StorageKeys.lastNotifiedGapSignature) == signature {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "今日の記録をつけてみませんか"
        content.body = "\(insight.blockTitle): \(insight.recommendation)"
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: "cognitive-gap-feedback",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["cognitive-gap-feedback"])
        try? await center.add(request)
        UserDefaults.standard.set(signature, forKey: StorageKeys.lastNotifiedGapSignature)
    }


    private static let demoReferenceDate = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 14, hour: 19, minute: 30)) ?? .now

    private static func makeDemoCategories(aligned: Bool = false) -> [MandalartCategory] {
        [
            MandalartCategory(
                id: 1, title: "GitHubで積み上げる", color: .blue,
                blocks: [
                    MandalartBlock(id: 101, title: "毎日3コミット出す", progress: aligned ? 92 : 55, resonance: 90, cleared: false),
                    MandalartBlock(id: 102, title: "レビュー依頼を投げる", progress: aligned ? 88 : 35, resonance: 76, cleared: false),
                    MandalartBlock(id: 103, title: "Issueを整理する", progress: aligned ? 75 : 42, resonance: 68, cleared: false),
                    MandalartBlock(id: 104, title: "PR本文を改善する", progress: aligned ? 64 : 20, resonance: 58, cleared: false),
                    MandalartBlock(id: 105, title: "READMEを磨く", progress: aligned ? 70 : 24, resonance: 52, cleared: false),
                    MandalartBlock(id: 106, title: "デモ環境を安定化", progress: aligned ? 82 : 46, resonance: 77, cleared: false),
                    MandalartBlock(id: 107, title: "CIエラーを潰す", progress: aligned ? 78 : 38, resonance: 66, cleared: false),
                    MandalartBlock(id: 108, title: "タグを揃える", progress: aligned ? 65 : 18, resonance: 44, cleared: false),
                ]
            ),
            MandalartCategory(
                id: 2, title: "発表準備を進める", color: .orange,
                blocks: [
                    MandalartBlock(id: 201, title: "プレゼンスライドを作る", progress: aligned ? 90 : 62, resonance: 88, cleared: false),
                    MandalartBlock(id: 202, title: "刺さる1シーンを磨く", progress: aligned ? 86 : 48, resonance: 95, cleared: false),
                    MandalartBlock(id: 203, title: "デモ台本を書く", progress: aligned ? 92 : 60, resonance: 90, cleared: false),
                    MandalartBlock(id: 204, title: "質疑応答を想定する", progress: aligned ? 73 : 34, resonance: 70, cleared: false),
                    MandalartBlock(id: 205, title: "3分で話せるようにする", progress: aligned ? 85 : 41, resonance: 82, cleared: false),
                    MandalartBlock(id: 206, title: "導入の一言を決める", progress: aligned ? 88 : 29, resonance: 76, cleared: false),
                    MandalartBlock(id: 207, title: "比較対象を整理する", progress: aligned ? 77 : 32, resonance: 58, cleared: false),
                    MandalartBlock(id: 208, title: "審査員への刺さりどころを言語化", progress: aligned ? 80 : 36, resonance: 74, cleared: false),
                ]
            ),
            MandalartCategory(
                id: 3, title: "行動を証拠に残す", color: .green,
                blocks: [
                    MandalartBlock(id: 301, title: "作業をCalendarに入れる", progress: aligned ? 82 : 30, resonance: 72, cleared: false),
                    MandalartBlock(id: 302, title: "作業ログを毎日振り返る", progress: aligned ? 91 : 44, resonance: 84, cleared: false),
                    MandalartBlock(id: 303, title: "終わった作業を記録する", progress: aligned ? 95 : 26, resonance: 94, cleared: false),
                    MandalartBlock(id: 304, title: "進捗をメンバー共有", progress: aligned ? 70 : 22, resonance: 52, cleared: false),
                    MandalartBlock(id: 305, title: "スクショを残す", progress: aligned ? 67 : 18, resonance: 40, cleared: false),
                    MandalartBlock(id: 306, title: "データを翌日に持ち越さない", progress: aligned ? 88 : 28, resonance: 81, cleared: false),
                    MandalartBlock(id: 307, title: "通知で自分を追い込む", progress: aligned ? 78 : 40, resonance: 74, cleared: false),
                    MandalartBlock(id: 308, title: "フィードバックを反映する", progress: aligned ? 83 : 12, resonance: 93, cleared: false),
                ]
            ),
            MandalartCategory(
                id: 4, title: "チームの温度を上げる", color: .purple,
                blocks: [
                    MandalartBlock(id: 401, title: "毎朝共有タイム", progress: aligned ? 88 : 58, resonance: 76, cleared: false),
                    MandalartBlock(id: 402, title: "詰まりをすぐ相談", progress: aligned ? 90 : 66, resonance: 88, cleared: false),
                    MandalartBlock(id: 403, title: "役割を明文化する", progress: aligned ? 81 : 30, resonance: 64, cleared: false),
                    MandalartBlock(id: 404, title: "不安を言葉にする", progress: aligned ? 78 : 24, resonance: 56, cleared: false),
                    MandalartBlock(id: 405, title: "レビューをポジティブに返す", progress: aligned ? 92 : 46, resonance: 80, cleared: false),
                    MandalartBlock(id: 406, title: "最後までやり切る", progress: aligned ? 96 : 64, resonance: 95, cleared: false),
                    MandalartBlock(id: 407, title: "焦りを可視化する", progress: aligned ? 75 : 18, resonance: 63, cleared: false),
                    MandalartBlock(id: 408, title: "プレッシャーを味方にする", progress: aligned ? 84 : 21, resonance: 78, cleared: false),
                ]
            )
        ]
    }

    private static func makeCognitiveGapJournalEntries(mainGoal: String) -> [JournalEntry] {
        [
            JournalEntry(id: "demo-github-1", date: demoReferenceDate.addingTimeInterval(-60 * 60 * 5), kind: .githubCommit, source: "GitHub", systemImageName: "chevron.left.forwardslash.chevron.right", iconHex: "18181b", action: "コミットを取得しました", detail: "feat: add github keyword sync to block detail", targetGoal: mainGoal, relatedBlockId: nil),
            JournalEntry(id: "demo-github-2", date: demoReferenceDate.addingTimeInterval(-60 * 60 * 4), kind: .githubCommit, source: "GitHub", systemImageName: "chevron.left.forwardslash.chevron.right", iconHex: "18181b", action: "コミットを取得しました", detail: "fix: offline banner and error handling", targetGoal: mainGoal, relatedBlockId: nil),
            JournalEntry(id: "demo-calendar-1", date: demoReferenceDate.addingTimeInterval(-60 * 60 * 3), kind: .calendarEvent, source: "Google Calendar", systemImageName: "calendar", iconHex: "2563eb", action: "予定を取得しました", detail: "デモ準備 ミーティング", targetGoal: mainGoal, relatedBlockId: nil),
            JournalEntry(id: "demo-manual-1", date: demoReferenceDate.addingTimeInterval(-60 * 90), kind: .manualCompleted, source: "Manual", systemImageName: "checkmark.circle.fill", iconHex: "22c55e", action: "アクションを完了しました", detail: "プレゼン練習（3分）", targetGoal: mainGoal, relatedBlockId: 205),
            JournalEntry(id: "demo-manual-2", date: demoReferenceDate.addingTimeInterval(-60 * 70), kind: .manualCompleted, source: "Manual", systemImageName: "checkmark.circle.fill", iconHex: "22c55e", action: "アクションを完了しました", detail: "スライドのフィードバック反映", targetGoal: mainGoal, relatedBlockId: 308),
            JournalEntry(id: "demo-system-1", date: demoReferenceDate.addingTimeInterval(-60 * 20), kind: .system, source: "System", systemImageName: "eye.trianglebadge.exclamationmark.fill", iconHex: "dc2626", action: "記録されていないアクションがあります", detail: "外部ログに対応する記録が見つかりませんでした", targetGoal: mainGoal, relatedBlockId: nil),
        ]
    }

    private static func makeAlignedJournalEntries(mainGoal: String) -> [JournalEntry] {
        [
            JournalEntry(id: "aligned-github-1", date: demoReferenceDate.addingTimeInterval(-60 * 60 * 4), kind: .githubCommit, source: "GitHub", systemImageName: "chevron.left.forwardslash.chevron.right", iconHex: "18181b", action: "コミットを取得しました", detail: "feat: add final pitch slides and demo assets", targetGoal: mainGoal, relatedBlockId: nil),
            JournalEntry(id: "aligned-calendar-1", date: demoReferenceDate.addingTimeInterval(-60 * 60 * 3), kind: .calendarEvent, source: "Google Calendar", systemImageName: "calendar", iconHex: "2563eb", action: "予定を取得しました", detail: "プレゼン練習 3分", targetGoal: mainGoal, relatedBlockId: nil),
            JournalEntry(id: "aligned-manual-1", date: demoReferenceDate.addingTimeInterval(-60 * 55), kind: .manualCompleted, source: "Manual", systemImageName: "checkmark.circle.fill", iconHex: "22c55e", action: "アクションを完了しました", detail: "プレゼンスライドを作る", targetGoal: mainGoal, relatedBlockId: 201),
            JournalEntry(id: "aligned-manual-2", date: demoReferenceDate.addingTimeInterval(-60 * 40), kind: .manualCompleted, source: "Manual", systemImageName: "checkmark.circle.fill", iconHex: "22c55e", action: "アクションを完了しました", detail: "作業をCalendarに入れる", targetGoal: mainGoal, relatedBlockId: 301),
            JournalEntry(id: "aligned-manual-3", date: demoReferenceDate.addingTimeInterval(-60 * 15), kind: .manualCompleted, source: "Manual", systemImageName: "checkmark.circle.fill", iconHex: "22c55e", action: "アクションを完了しました", detail: "詰まりをすぐ相談", targetGoal: mainGoal, relatedBlockId: 402),
            JournalEntry(id: "aligned-system-1", date: demoReferenceDate.addingTimeInterval(-60 * 5), kind: .system, source: "System", systemImageName: "star.fill", iconHex: "22c55e", action: "記録と行動が一致しています", detail: "GitHubのコミットと記録が対応しています", targetGoal: mainGoal, relatedBlockId: nil),
        ]
    }

    private func dayIdentifier(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func persistState() {
        guard !isPersistingState else { return }
        isPersistingState = true
        defer { isPersistingState = false }

        let state = PersistedAppState(
            mainGoal: mainGoal,
            categories: categories,
            journalEntries: journalEntries,
            gapInsights: gapInsights,
            githubSettings: githubSettings,
            googleCalendarSettings: googleCalendarSettings,
            notificationsEnabled: notificationsEnabled
        )

        persistStateToSwiftData(state)
        persistCloudSyncDraft(state)

        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.appState)
    }

    private func persistStateToSwiftData(_ state: PersistedAppState) {
        do {
            // Settings
            let settings = Self.loadStoredSettings(modelContext: modelContext)
                ?? {
                    let record = StoredSettings(
                        mainGoal: state.mainGoal,
                        githubOwner: state.githubSettings.owner,
                        githubRepository: state.githubSettings.repository,
                        githubHasPersonalAccessToken: state.githubSettings.hasPersonalAccessToken,
                        googleCalendarID: state.googleCalendarSettings.calendarId,
                        googleCalendarHasAccessToken: state.googleCalendarSettings.hasAccessToken,
                        notificationsEnabled: state.notificationsEnabled
                    )
                    modelContext.insert(record)
                    return record
                }()

            settings.mainGoal = state.mainGoal
            settings.githubOwner = state.githubSettings.owner
            settings.githubRepository = state.githubSettings.repository
            settings.githubHasPersonalAccessToken = state.githubSettings.hasPersonalAccessToken
            settings.googleCalendarID = state.googleCalendarSettings.calendarId
            settings.googleCalendarHasAccessToken = state.googleCalendarSettings.hasAccessToken
            settings.notificationsEnabled = state.notificationsEnabled
            settings.lastCloudSyncAt = lastCloudSyncAt
            settings.cloudSyncStatusMessage = cloudSyncStatusMessage

            // Replace category tree
            try modelContext.fetch(FetchDescriptor<StoredCategory>())
                .forEach { modelContext.delete($0) }
            try modelContext.save()

            for category in state.categories {
                let categoryRecord = StoredCategory(
                    id: category.id,
                    title: category.title,
                    colorRaw: category.color.rawValue
                )
                modelContext.insert(categoryRecord)

                for block in category.blocks {
                    let blockRecord = StoredBlock(
                        id: block.id,
                        title: block.title,
                        progress: block.progress,
                        resonance: block.resonance,
                        cleared: block.cleared,
                        category: categoryRecord
                    )
                    categoryRecord.blocks.append(blockRecord)
                    modelContext.insert(blockRecord)
                }
            }

            // Replace journals
            try modelContext.fetch(FetchDescriptor<StoredJournalEntry>())
                .forEach { modelContext.delete($0) }
            try modelContext.save()

            for entry in state.journalEntries {
                modelContext.insert(
                    StoredJournalEntry(
                        id: entry.id,
                        date: entry.date,
                        kindRaw: entry.kind.rawValue,
                        source: entry.source,
                        systemImageName: entry.systemImageName,
                        iconHex: entry.iconHex,
                        action: entry.action,
                        detail: entry.detail,
                        targetGoal: entry.targetGoal,
                        relatedBlockId: entry.relatedBlockId
                    )
                )
            }

            // Replace gap insights
            try modelContext.fetch(FetchDescriptor<StoredGapInsight>())
                .forEach { modelContext.delete($0) }
            try modelContext.save()

            for insight in state.gapInsights {
                modelContext.insert(
                    StoredGapInsight(
                        id: insight.id,
                        generatedAt: insight.generatedAt,
                        blockId: insight.blockId,
                        blockTitle: insight.blockTitle,
                        categoryTitle: insight.categoryTitle,
                        score: insight.score,
                        severityRaw: insight.severity.rawValue,
                        selfReportedCompleted: insight.selfReportedCompleted,
                        matchedEvidenceCount: insight.matchedEvidenceCount,
                        matchedSourcesRaw: insight.matchedSources.joined(separator: ","),
                        summary: insight.summary,
                        recommendation: insight.recommendation
                    )
                )
            }

            try modelContext.save()
        } catch {
            cloudSyncStatusMessage = "SwiftData 保存失敗: \(error.localizedDescription)"
        }
    }

    private func persistCloudSyncDraft(_ state: PersistedAppState) {
        let envelope = CloudSyncEnvelope(
            exportedAt: Date(),
            mainGoal: state.mainGoal,
            categories: state.categories,
            journalEntries: state.journalEntries,
            gapInsights: state.gapInsights,
            githubSettings: state.githubSettings,
            googleCalendarSettings: state.googleCalendarSettings,
            notificationsEnabled: state.notificationsEnabled
        )

        do {
            try cloudSyncService.push(envelope)
        } catch {
            cloudSyncStatusMessage = "クラウド同期ドラフト更新失敗: \(error.localizedDescription)"
        }
    }

    private static func loadStoredSettings(modelContext: ModelContext) -> StoredSettings? {
        try? modelContext.fetch(FetchDescriptor<StoredSettings>()).first
    }

    private static func loadPersistedState(modelContext: ModelContext) -> PersistedAppState? {
        guard let settings = loadStoredSettings(modelContext: modelContext) else {
            return nil
        }

        let categories = (try? modelContext.fetch(FetchDescriptor<StoredCategory>()))?
            .sorted { $0.id < $1.id }
            .map(MandalartCategory.init(record:)) ?? []

        let journalEntries = (try? modelContext.fetch(FetchDescriptor<StoredJournalEntry>()))?
            .sorted { $0.date > $1.date }
            .map(JournalEntry.init(record:)) ?? []

        let gapInsights = (try? modelContext.fetch(FetchDescriptor<StoredGapInsight>()))?
            .sorted { $0.score > $1.score }
            .map(CognitiveGapInsight.init(record:)) ?? []

        guard !categories.isEmpty || !journalEntries.isEmpty || !gapInsights.isEmpty else {
            return nil
        }

        return PersistedAppState(
            mainGoal: settings.mainGoal,
            categories: categories.isEmpty ? PersistedAppState.default.categories : categories,
            journalEntries: journalEntries.isEmpty ? PersistedAppState.default.journalEntries : journalEntries,
            gapInsights: gapInsights,
            githubSettings: GitHubSettings(
                owner: settings.githubOwner,
                repository: settings.githubRepository,
                hasPersonalAccessToken: settings.githubHasPersonalAccessToken
            ),
            googleCalendarSettings: GoogleCalendarSettings(
                calendarId: settings.googleCalendarID,
                hasAccessToken: settings.googleCalendarHasAccessToken
            ),
            notificationsEnabled: settings.notificationsEnabled
        )
    }

    private static func loadPersistedState() -> PersistedAppState {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.appState),
              let decoded = try? JSONDecoder().decode(PersistedAppState.self, from: data) else {
            return .default
        }
        return decoded
    }
}
