import SwiftUI

// MARK: - Category Color
enum CategoryColor: String, CaseIterable, Identifiable {
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
struct MandalartBlock: Identifiable {
    let id: Int
    var title: String
    var progress: Double  // 0–100
    var resonance: Double // 0–100
    var cleared: Bool
}

// MARK: - Mandalart Category
struct MandalartCategory: Identifiable {
    let id: Int
    var title: String
    var color: CategoryColor
    var blocks: [MandalartBlock]
}

// MARK: - Daily Task (checkin card)
struct DailyTask: Identifiable {
    let id: Int
    let title: String
    let category: String
    let theme: CategoryColor
}

// MARK: - Journal Entry
struct JournalEntry: Identifiable {
    let id: Int
    let time: String
    let source: String
    let systemImageName: String
    let iconBgColor: Color
    let action: String
    let detail: String
    let targetGoal: String
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
        DailyTask(id: 1, title: "1日1時間のコーディング", category: "技術力",   theme: .blue),
        DailyTask(id: 2, title: "OSSにPRを出す",          category: "技術力",   theme: .blue),
        DailyTask(id: 3, title: "週1回ブログ更新",        category: "発信力",   theme: .orange),
        DailyTask(id: 4, title: "Twitterで毎日発信",      category: "発信力",   theme: .orange),
        DailyTask(id: 5, title: "週3回の筋トレ",          category: "健康",     theme: .green),
        DailyTask(id: 6, title: "他者と比較しない",       category: "マインド", theme: .purple),
    ]
}

extension JournalEntry {
    static let sampleEntries: [JournalEntry] = [
        JournalEntry(id: 1, time: "09:30", source: "GitHub",         systemImageName: "chevron.left.forwardslash.chevron.right", iconBgColor: Color(hex: "18181b"), action: "リポジトリにコミットしました",    detail: "feat: add user authentication", targetGoal: "技術スキルの向上"),
        JournalEntry(id: 2, time: "12:00", source: "Google Calendar", systemImageName: "calendar",                                iconBgColor: Color(hex: "2563eb"), action: "予定を完了しました",              detail: "1on1 ミーティング",              targetGoal: "チームとの信頼構築"),
        JournalEntry(id: 3, time: "15:45", source: "Manual",          systemImageName: "checkmark.circle.fill",                   iconBgColor: Color(hex: "22c55e"), action: "アクションを完了しました",        detail: "技術書を1章読む",               targetGoal: "技術スキルの向上"),
        JournalEntry(id: 4, time: "18:20", source: "System",          systemImageName: "star.fill",                               iconBgColor: Color(hex: "fbbf24"), action: "目標の達成率がアップ！",          detail: "今日の行動が目標に大きく貢献しました", targetGoal: "全般"),
    ]
}
