import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    private enum StorageKeys {
        static let appState = "mandalart-sync.app-state"
    }

    private enum SecretKeys {
        static let service = "mandalart-sync.credentials"
        static let githubToken = "github.personal-access-token"
        static let googleCalendarToken = "google-calendar.access-token"
    }

    private let gitHubService: GitHubCommitFetching
    private let googleCalendarService: GoogleCalendarFetching

    @Published var mainGoal: String {
        didSet { persistState() }
    }
    @Published var categories: [MandalartCategory] {
        didSet { persistState() }
    }
    @Published var journalEntries: [JournalEntry] {
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

    init(
        gitHubService: GitHubCommitFetching = GitHubService(),
        googleCalendarService: GoogleCalendarFetching = GoogleCalendarService()
    ) {
        self.gitHubService = gitHubService
        self.googleCalendarService = googleCalendarService
        let state = Self.loadPersistedState()
        self.mainGoal = state.mainGoal
        self.categories = state.categories
        self.journalEntries = state.journalEntries.sorted { $0.date > $1.date }
        self.githubSettings = state.githubSettings
        self.googleCalendarSettings = state.googleCalendarSettings
        self.notificationsEnabled = state.notificationsEnabled
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

    var hasGitHubToken: Bool {
        !(storedGitHubToken()?.isEmpty ?? true)
    }

    var hasGoogleCalendarToken: Bool {
        !(storedGoogleCalendarAccessToken()?.isEmpty ?? true)
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

    func updateGitHubSettings(owner: String, repository: String, token: String) {
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

    func resetAllData() {
        let state = PersistedAppState.default
        mainGoal = state.mainGoal
        categories = state.categories
        journalEntries = state.journalEntries
        githubSettings = state.githubSettings
        googleCalendarSettings = state.googleCalendarSettings
        notificationsEnabled = state.notificationsEnabled
        KeychainStore.delete(service: SecretKeys.service, account: SecretKeys.githubToken)
        KeychainStore.delete(service: SecretKeys.service, account: SecretKeys.googleCalendarToken)
        syncErrorMessage = nil
    }

    func triggerSync() {
        guard !isSyncing else { return }
        isSyncing = true
        syncErrorMessage = nil

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
                owner: githubSettings.owner,
                repository: githubSettings.repository,
                token: storedGitHubToken()
            )
            let entries = commits.map { commit in
                JournalEntry(
                    id: "github-\(commit.sha)",
                    date: commit.commit.author?.date ?? Date(),
                    kind: .githubCommit,
                    source: "GitHub",
                    systemImageName: "chevron.left.forwardslash.chevron.right",
                    iconHex: "18181b",
                    action: "コミットを取得しました",
                    detail: commit.commit.message.components(separatedBy: .newlines).first ?? "Recent commit",
                    targetGoal: mainGoal,
                    relatedBlockId: nil
                )
            }
            replaceEntries(of: .githubCommit, with: entries)
            summary.append("GitHub \(entries.count)件")
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
            } catch {
                failures.append(error.localizedDescription)
            }
        } else {
            summary.append("Google Calendar 未設定")
        }

        if summary.isEmpty {
            appendSystemEntry(
                action: "同期対象が未設定です",
                detail: "設定画面で GitHub / Google Calendar の連携先を入力してください。"
            )
        } else {
            appendSystemEntry(
                action: failures.isEmpty ? "同期が完了しました" : "一部の同期が完了しました",
                detail: summary.joined(separator: " / ")
            )
        }

        if failures.isEmpty {
            syncErrorMessage = nil
        } else {
            syncErrorMessage = failures.joined(separator: "\n")
        }
    }

    private func persistState() {
        let state = PersistedAppState(
            mainGoal: mainGoal,
            categories: categories,
            journalEntries: journalEntries,
            githubSettings: githubSettings,
            googleCalendarSettings: googleCalendarSettings,
            notificationsEnabled: notificationsEnabled
        )

        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.appState)
    }

    private static func loadPersistedState() -> PersistedAppState {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.appState),
              let decoded = try? JSONDecoder().decode(PersistedAppState.self, from: data) else {
            return .default
        }
        return decoded
    }
}
