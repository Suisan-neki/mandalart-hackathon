import SwiftUI
import SwiftData

// MARK: - Category Color
enum CategoryColor: String, CaseIterable, Identifiable, Codable {
    case blue, orange, green, purple

    var id: String { rawValue }

    var primary: Color {
        switch self {
        case .blue:   return Color(hex: "3b82f6")
        case .orange: return Color(hex: "f97316")
        case .green:  return Color(hex: "22c55e")
        case .purple: return Color(hex: "a855f7")
        }
    }

    var dark: Color {
        switch self {
        case .blue:   return Color(hex: "1d4ed8")
        case .orange: return Color(hex: "c2410c")
        case .green:  return Color(hex: "15803d")
        case .purple: return Color(hex: "7e22ce")
        }
    }

    var light: Color { primary.opacity(0.15) }

    var border: Color { primary.opacity(0.4) }

    var textColor: Color { primary }
}

// MARK: - Mandalart Block
struct MandalartBlock: Identifiable, Codable, Equatable {
    let id: Int
    var title: String
    var progress: Double  // 0–100
    var resonance: Double // 0–100
    var cleared: Bool
}

// MARK: - Mandalart Category
struct MandalartCategory: Identifiable, Codable, Equatable {
    let id: Int
    var title: String
    var color: CategoryColor
    var blocks: [MandalartBlock]
}

// MARK: - Daily Task (checkin card)
struct DailyTask: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let blockId: Int
    let categoryId: Int
    let category: String
    let theme: CategoryColor
    let targetGoal: String
}

// MARK: - Checkin Result
enum CheckinAnswer: String, Codable, CaseIterable {
    case completed
    case skipped
}

// MARK: - Journal Kind
enum JournalEntryKind: String, Codable {
    case githubCommit
    case calendarEvent
    case manualCompleted
    case manualSkipped
    case system
}

// MARK: - Journal Entry
struct JournalEntry: Identifiable, Codable, Equatable {
    let id: String
    let date: Date
    let kind: JournalEntryKind
    let source: String
    let systemImageName: String
    let iconHex: String
    let action: String
    let detail: String
    let targetGoal: String
    let relatedBlockId: Int?

    var iconBgColor: Color {
        Color(hex: iconHex)
    }

    var time: String {
        Self.timeFormatter.string(from: date)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

// MARK: - Cognitive Gap
enum CognitiveGapSeverity: String, Codable, CaseIterable {
    case aligned
    case caution
    case warning
    case critical

    var rank: Int {
        switch self {
        case .aligned: return 0
        case .caution: return 1
        case .warning: return 2
        case .critical: return 3
        }
    }
}

struct CognitiveGapInsight: Identifiable, Codable, Equatable {
    let id: String
    let generatedAt: Date
    let blockId: Int
    let blockTitle: String
    let categoryTitle: String
    let score: Int
    let severity: CognitiveGapSeverity
    let selfReportedCompleted: Bool
    let matchedEvidenceCount: Int
    let matchedSources: [String]
    let summary: String
    let recommendation: String
}

// MARK: - Service Settings
struct GitHubSettings: Codable, Equatable {
    var owner: String
    var repository: String
    var hasPersonalAccessToken: Bool

    static let `default` = GitHubSettings(
        owner: "Suisan-neki",
        repository: "mandalart-hackathon",
        hasPersonalAccessToken: false
    )
}

struct GoogleCalendarSettings: Codable, Equatable {
    var calendarId: String
    var hasAccessToken: Bool

    static let `default` = GoogleCalendarSettings(
        calendarId: "primary",
        hasAccessToken: false
    )
}

// MARK: - Persisted State
struct PersistedAppState: Codable {
    var mainGoal: String
    var categories: [MandalartCategory]
    var journalEntries: [JournalEntry]
    var gapInsights: [CognitiveGapInsight]
    var githubSettings: GitHubSettings
    var googleCalendarSettings: GoogleCalendarSettings
    var notificationsEnabled: Bool
    var intenseEffectsEnabled: Bool

    static let `default` = PersistedAppState(
        mainGoal: "最強のエンジニアになる",
        categories: MandalartCategory.sampleData,
        journalEntries: JournalEntry.sampleEntries,
        gapInsights: [],
        githubSettings: .default,
        googleCalendarSettings: .default,
        notificationsEnabled: true,
        intenseEffectsEnabled: true
    )

    private enum CodingKeys: String, CodingKey {
        case mainGoal
        case categories
        case journalEntries
        case gapInsights
        case githubSettings
        case googleCalendarSettings
        case notificationsEnabled
        case intenseEffectsEnabled
    }

    init(
        mainGoal: String,
        categories: [MandalartCategory],
        journalEntries: [JournalEntry],
        gapInsights: [CognitiveGapInsight],
        githubSettings: GitHubSettings,
        googleCalendarSettings: GoogleCalendarSettings,
        notificationsEnabled: Bool,
        intenseEffectsEnabled: Bool
    ) {
        self.mainGoal = mainGoal
        self.categories = categories
        self.journalEntries = journalEntries
        self.gapInsights = gapInsights
        self.githubSettings = githubSettings
        self.googleCalendarSettings = googleCalendarSettings
        self.notificationsEnabled = notificationsEnabled
        self.intenseEffectsEnabled = intenseEffectsEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mainGoal = try container.decode(String.self, forKey: .mainGoal)
        self.categories = try container.decode([MandalartCategory].self, forKey: .categories)
        self.journalEntries = try container.decode([JournalEntry].self, forKey: .journalEntries)
        self.gapInsights = try container.decodeIfPresent([CognitiveGapInsight].self, forKey: .gapInsights) ?? []
        self.githubSettings = try container.decodeIfPresent(GitHubSettings.self, forKey: .githubSettings) ?? .default
        self.googleCalendarSettings = try container.decodeIfPresent(GoogleCalendarSettings.self, forKey: .googleCalendarSettings) ?? .default
        self.notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        self.intenseEffectsEnabled = try container.decodeIfPresent(Bool.self, forKey: .intenseEffectsEnabled) ?? true
    }
}

// MARK: - Cloud Sync Envelope
struct CloudSyncEnvelope: Codable {
    let exportedAt: Date
    let mainGoal: String
    let categories: [MandalartCategory]
    let journalEntries: [JournalEntry]
    let gapInsights: [CognitiveGapInsight]
    let githubSettings: GitHubSettings
    let googleCalendarSettings: GoogleCalendarSettings
    let notificationsEnabled: Bool
    let intenseEffectsEnabled: Bool
}

// MARK: - Demo Mode
enum DemoScenarioPreset: String, CaseIterable, Identifiable {
    case cognitiveGap
    case alignedMomentum
    case apiError

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cognitiveGap:
            return "ズレありシナリオ"
        case .alignedMomentum:
            return "順調シナリオ"
        case .apiError:
            return "APIエラーシナリオ"
        }
    }

    var subtitle: String {
        switch self {
        case .cognitiveGap:
            return "チェックインと外部ログにズレがある状態"
        case .alignedMomentum:
            return "チェックインと外部ログが一致している状態"
        case .apiError:
            return "同期失敗時の動作を確認する"
        }
    }
}

struct DemoScenarioStep: Identifiable {
    let id: String
    let title: String
    let detail: String
}

// MARK: - SwiftData Models
@Model
final class StoredCategory {
    @Attribute(.unique) var id: Int
    var title: String
    var colorRaw: String
    @Relationship(deleteRule: .cascade, inverse: \StoredBlock.category) var blocks: [StoredBlock]

    init(id: Int, title: String, colorRaw: String, blocks: [StoredBlock] = []) {
        self.id = id
        self.title = title
        self.colorRaw = colorRaw
        self.blocks = blocks
    }
}

@Model
final class StoredBlock {
    @Attribute(.unique) var id: Int
    var title: String
    var progress: Double
    var resonance: Double
    var cleared: Bool
    var category: StoredCategory?

    init(id: Int, title: String, progress: Double, resonance: Double, cleared: Bool, category: StoredCategory? = nil) {
        self.id = id
        self.title = title
        self.progress = progress
        self.resonance = resonance
        self.cleared = cleared
        self.category = category
    }
}

@Model
final class StoredJournalEntry {
    @Attribute(.unique) var id: String
    var date: Date
    var kindRaw: String
    var source: String
    var systemImageName: String
    var iconHex: String
    var action: String
    var detail: String
    var targetGoal: String
    var relatedBlockId: Int?

    init(
        id: String,
        date: Date,
        kindRaw: String,
        source: String,
        systemImageName: String,
        iconHex: String,
        action: String,
        detail: String,
        targetGoal: String,
        relatedBlockId: Int?
    ) {
        self.id = id
        self.date = date
        self.kindRaw = kindRaw
        self.source = source
        self.systemImageName = systemImageName
        self.iconHex = iconHex
        self.action = action
        self.detail = detail
        self.targetGoal = targetGoal
        self.relatedBlockId = relatedBlockId
    }
}

@Model
final class StoredGapInsight {
    @Attribute(.unique) var id: String
    var generatedAt: Date
    var blockId: Int
    var blockTitle: String
    var categoryTitle: String
    var score: Int
    var severityRaw: String
    var selfReportedCompleted: Bool
    var matchedEvidenceCount: Int
    var matchedSourcesRaw: String
    var summary: String
    var recommendation: String

    init(
        id: String,
        generatedAt: Date,
        blockId: Int,
        blockTitle: String,
        categoryTitle: String,
        score: Int,
        severityRaw: String,
        selfReportedCompleted: Bool,
        matchedEvidenceCount: Int,
        matchedSourcesRaw: String,
        summary: String,
        recommendation: String
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.blockId = blockId
        self.blockTitle = blockTitle
        self.categoryTitle = categoryTitle
        self.score = score
        self.severityRaw = severityRaw
        self.selfReportedCompleted = selfReportedCompleted
        self.matchedEvidenceCount = matchedEvidenceCount
        self.matchedSourcesRaw = matchedSourcesRaw
        self.summary = summary
        self.recommendation = recommendation
    }
}

@Model
final class StoredSettings {
    @Attribute(.unique) var id: String
    var mainGoal: String
    var githubOwner: String
    var githubRepository: String
    var githubHasPersonalAccessToken: Bool
    var googleCalendarID: String
    var googleCalendarHasAccessToken: Bool
    var notificationsEnabled: Bool
    var intenseEffectsEnabled: Bool
    var lastCloudSyncAt: Date?
    var cloudSyncStatusMessage: String?

    init(
        id: String = "app-settings",
        mainGoal: String,
        githubOwner: String,
        githubRepository: String,
        githubHasPersonalAccessToken: Bool,
        googleCalendarID: String,
        googleCalendarHasAccessToken: Bool,
        notificationsEnabled: Bool,
        intenseEffectsEnabled: Bool,
        lastCloudSyncAt: Date? = nil,
        cloudSyncStatusMessage: String? = nil
    ) {
        self.id = id
        self.mainGoal = mainGoal
        self.githubOwner = githubOwner
        self.githubRepository = githubRepository
        self.githubHasPersonalAccessToken = githubHasPersonalAccessToken
        self.googleCalendarID = googleCalendarID
        self.googleCalendarHasAccessToken = googleCalendarHasAccessToken
        self.notificationsEnabled = notificationsEnabled
        self.intenseEffectsEnabled = intenseEffectsEnabled
        self.lastCloudSyncAt = lastCloudSyncAt
        self.cloudSyncStatusMessage = cloudSyncStatusMessage
    }
}

// MARK: - SwiftData Mapping
extension MandalartCategory {
    init(record: StoredCategory) {
        self.init(
            id: record.id,
            title: record.title,
            color: CategoryColor(rawValue: record.colorRaw) ?? .blue,
            blocks: record.blocks
                .sorted { $0.id < $1.id }
                .map(MandalartBlock.init(record:))
        )
    }
}

extension MandalartBlock {
    init(record: StoredBlock) {
        self.init(
            id: record.id,
            title: record.title,
            progress: record.progress,
            resonance: record.resonance,
            cleared: record.cleared
        )
    }
}

extension JournalEntry {
    init(record: StoredJournalEntry) {
        self.init(
            id: record.id,
            date: record.date,
            kind: JournalEntryKind(rawValue: record.kindRaw) ?? .system,
            source: record.source,
            systemImageName: record.systemImageName,
            iconHex: record.iconHex,
            action: record.action,
            detail: record.detail,
            targetGoal: record.targetGoal,
            relatedBlockId: record.relatedBlockId
        )
    }
}

extension CognitiveGapInsight {
    init(record: StoredGapInsight) {
        self.init(
            id: record.id,
            generatedAt: record.generatedAt,
            blockId: record.blockId,
            blockTitle: record.blockTitle,
            categoryTitle: record.categoryTitle,
            score: record.score,
            severity: CognitiveGapSeverity(rawValue: record.severityRaw) ?? .aligned,
            selfReportedCompleted: record.selfReportedCompleted,
            matchedEvidenceCount: record.matchedEvidenceCount,
            matchedSources: record.matchedSourcesRaw
                .split(separator: ",")
                .map(String.init)
                .filter { !$0.isEmpty },
            summary: record.summary,
            recommendation: record.recommendation
        )
    }
}

// MARK: - Sample Data
extension MandalartCategory {
    static let sampleData: [MandalartCategory] = [
        MandalartCategory(
            id: 1, title: "圧倒的な技術力", color: .blue,
            blocks: [
                MandalartBlock(id: 101, title: "1日1時間のコーディング", progress: 80, resonance: 90, cleared: false),
                MandalartBlock(id: 102, title: "新しい言語を触る",       progress: 40, resonance: 60, cleared: false),
                MandalartBlock(id: 103, title: "OSSにPRを出す",          progress: 10, resonance: 30, cleared: false),
                MandalartBlock(id: 104, title: "技術書を月1冊読む",      progress: 100, resonance: 95, cleared: true),
                MandalartBlock(id: 105, title: "アルゴリズムを解く",     progress: 20, resonance: 40, cleared: false),
                MandalartBlock(id: 106, title: "アーキテクチャを学ぶ",  progress: 60, resonance: 70, cleared: false),
                MandalartBlock(id: 107, title: "パフォーマンスチューニング", progress: 5, resonance: 20, cleared: false),
                MandalartBlock(id: 108, title: "コードレビュー依頼",     progress: 50, resonance: 80, cleared: false),
            ]
        ),
        MandalartCategory(
            id: 2, title: "継続的な発信力", color: .orange,
            blocks: [
                MandalartBlock(id: 201, title: "週1回ブログ更新",        progress: 70, resonance: 85, cleared: false),
                MandalartBlock(id: 202, title: "Twitterで毎日発信",      progress: 90, resonance: 90, cleared: false),
                MandalartBlock(id: 203, title: "LT会に月1回登壇",        progress: 30, resonance: 50, cleared: false),
                MandalartBlock(id: 204, title: "Qiitaで記事作成",        progress: 50, resonance: 70, cleared: false),
                MandalartBlock(id: 205, title: "勉強会を主催する",       progress: 0,  resonance: 10, cleared: false),
                MandalartBlock(id: 206, title: "Podcastを始める",        progress: 10, resonance: 40, cleared: false),
                MandalartBlock(id: 207, title: "ポートフォリオ更新",     progress: 100, resonance: 100, cleared: true),
                MandalartBlock(id: 208, title: "YouTubeで解説動画",      progress: 0,  resonance: 20, cleared: false),
            ]
        ),
        MandalartCategory(
            id: 3, title: "強靭な肉体と健康", color: .green,
            blocks: [
                MandalartBlock(id: 301, title: "週3回の筋トレ",          progress: 60, resonance: 80, cleared: false),
                MandalartBlock(id: 302, title: "毎朝ランニング",          progress: 40, resonance: 50, cleared: false),
                MandalartBlock(id: 303, title: "7時間以上の睡眠",        progress: 90, resonance: 95, cleared: false),
                MandalartBlock(id: 304, title: "ジャンクフード禁止",     progress: 20, resonance: 30, cleared: false),
                MandalartBlock(id: 305, title: "プロテイン摂取",         progress: 80, resonance: 80, cleared: false),
                MandalartBlock(id: 306, title: "瞑想10分",               progress: 50, resonance: 60, cleared: false),
                MandalartBlock(id: 307, title: "姿勢改善ストレッチ",     progress: 70, resonance: 75, cleared: false),
                MandalartBlock(id: 308, title: "水分2リットル",          progress: 100, resonance: 90, cleared: true),
            ]
        ),
        MandalartCategory(
            id: 4, title: "マインドセット", color: .purple,
            blocks: [
                MandalartBlock(id: 401, title: "自己否定をしない",       progress: 50, resonance: 70, cleared: false),
                MandalartBlock(id: 402, title: "他者と比較しない",       progress: 60, resonance: 80, cleared: false),
                MandalartBlock(id: 403, title: "毎日3つの感謝",          progress: 80, resonance: 90, cleared: false),
                MandalartBlock(id: 404, title: "失敗を恐れない",         progress: 40, resonance: 50, cleared: false),
                MandalartBlock(id: 405, title: "完璧主義を捨てる",       progress: 70, resonance: 85, cleared: false),
                MandalartBlock(id: 406, title: "とりあえず始める",       progress: 90, resonance: 95, cleared: false),
                MandalartBlock(id: 407, title: "フィードバック歓迎",     progress: 100, resonance: 100, cleared: true),
                MandalartBlock(id: 408, title: "常に好奇心を持つ",       progress: 80, resonance: 80, cleared: false),
            ]
        ),
    ]
}

extension DailyTask {
    static let sampleTasks: [DailyTask] = [
        DailyTask(id: 1, title: "1日1時間のコーディング", blockId: 101, categoryId: 1, category: "技術力",   theme: .blue, targetGoal: "最強のエンジニアになる"),
        DailyTask(id: 2, title: "OSSにPRを出す",          blockId: 103, categoryId: 1, category: "技術力",   theme: .blue, targetGoal: "最強のエンジニアになる"),
        DailyTask(id: 3, title: "週1回ブログ更新",        blockId: 201, categoryId: 2, category: "発信力",   theme: .orange, targetGoal: "最強のエンジニアになる"),
        DailyTask(id: 4, title: "Twitterで毎日発信",      blockId: 202, categoryId: 2, category: "発信力",   theme: .orange, targetGoal: "最強のエンジニアになる"),
        DailyTask(id: 5, title: "週3回の筋トレ",          blockId: 301, categoryId: 3, category: "健康",     theme: .green, targetGoal: "最強のエンジニアになる"),
        DailyTask(id: 6, title: "他者と比較しない",       blockId: 402, categoryId: 4, category: "マインド", theme: .purple, targetGoal: "最強のエンジニアになる"),
    ]
}

extension JournalEntry {
    static let sampleEntries: [JournalEntry] = [
        JournalEntry(id: "sample-github-1", date: .now.addingTimeInterval(-60 * 60 * 9), kind: .githubCommit, source: "GitHub", systemImageName: "chevron.left.forwardslash.chevron.right", iconHex: "18181b", action: "リポジトリにコミットしました", detail: "feat: add user authentication", targetGoal: "技術スキルの向上", relatedBlockId: 101),
        JournalEntry(id: "sample-calendar-1", date: .now.addingTimeInterval(-60 * 60 * 6), kind: .calendarEvent, source: "Google Calendar", systemImageName: "calendar", iconHex: "2563eb", action: "予定を完了しました", detail: "1on1 ミーティング", targetGoal: "チームとの信頼構築", relatedBlockId: nil),
        JournalEntry(id: "sample-manual-1", date: .now.addingTimeInterval(-60 * 60 * 3), kind: .manualCompleted, source: "Manual", systemImageName: "checkmark.circle.fill", iconHex: "22c55e", action: "アクションを完了しました", detail: "技術書を1章読む", targetGoal: "技術スキルの向上", relatedBlockId: 104),
        JournalEntry(id: "sample-system-1", date: .now.addingTimeInterval(-60 * 60), kind: .system, source: "System", systemImageName: "star.fill", iconHex: "fbbf24", action: "目標の達成率がアップ！", detail: "今日の行動が目標に大きく貢献しました", targetGoal: "全般", relatedBlockId: nil),
    ]
}
