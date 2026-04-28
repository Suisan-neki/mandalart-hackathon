import SwiftUI

struct SyncJournalView: View {
    @EnvironmentObject private var vm: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日の行動ログ")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color.stone900)
                    Text("記録や同期で取得した行動を時系列で確認できます。")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.stone500)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 28)

                // Timeline
                if vm.journalEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 32))
                            .foregroundColor(Color.stone300)
                        Text("まだ記録がありません")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.stone400)
                        Text("「今日の記録」から記録するか、同期ボタンを押してみてください。")
                            .font(.system(size: 12))
                            .foregroundColor(Color.stone400)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 24)
                } else {
                    ZStack(alignment: .topLeading) {
                        // Vertical line
                        Rectangle()
                            .fill(Color.stone200)
                            .frame(width: 1)
                            .padding(.leading, 39)
                            .padding(.top, 4)

                        VStack(spacing: 28) {
                            ForEach(vm.journalEntries) { entry in
                                TimelineRow(entry: entry)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Encouragement card
                encouragementCard
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 32)
            }
        }
        .background(Color.stone50.ignoresSafeArea())
        .navigationTitle("行動ログ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var encouragementCard: some View {
        let count = vm.journalEntries.count
        let headline: String
        let body: String
        if count == 0 {
            headline = "まず1つ記録してみよう"
            body = "「今日の記録」から始めると、行動が記録として積み上がっていきます。"
        } else if count < 5 {
            headline = "記録が残っている"
            body = "少しでも動いた分が記録に残る。それだけで十分。"
        } else {
            headline = "今日もおつかれさまでした"
            body = "記録が残ること自体が前進の証拠。明日もその調子で。"
        }
        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.05), radius: 6)
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.amber500)
            }
            Text(headline)
                .font(.system(size: 17, weight: .black))
                .foregroundColor(Color(hex: "92400e"))
            Text(body)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "b45309").opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(hex: "fffbeb"), Color(hex: "fff7ed")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28).stroke(Color(hex: "fde68a"), lineWidth: 0.5)
        )
    }
}

// MARK: - Timeline Row
struct TimelineRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon + time
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(entry.iconBgColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: entry.systemImageName)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                }
                Text(entry.time)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.stone400)
            }

            // Content card
            VStack(alignment: .leading, spacing: 6) {
                // Goal tag
                HStack(spacing: 4) {
                    Image(systemName: "scope")
                        .font(.system(size: 9))
                        .foregroundColor(Color.red500)
                    Text(entry.targetGoal)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color.red500)
                        .tracking(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red500.opacity(0.06))
                .clipShape(Capsule())

                Text(entry.action)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.stone800)

                Text(entry.detail)
                    .font(.system(size: 12))
                    .foregroundColor(Color.stone500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18).stroke(Color.stone100, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        }
    }
}

#Preview {
    NavigationStack {
        SyncJournalView()
    }
    .environmentObject(AppViewModel())
}
