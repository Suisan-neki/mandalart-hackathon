import SwiftUI

struct SyncJournalView: View {
    @EnvironmentObject private var vm: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日の積み上げ")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color.stone900)
                    Text("あなたの行動一つ一つが、目標という形になって確実に積み上がっています。")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.stone500)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 28)

                // Timeline
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

                // Encouragement card
                encouragementCard
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 32)
            }
        }
        .background(Color.stone50.ignoresSafeArea())
        .navigationTitle("アクション・ジャーナル")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var encouragementCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.05), radius: 6)
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.amber500)
            }
            Text("素晴らしい1日でした")
                .font(.system(size: 17, weight: .black))
                .foregroundColor(Color(hex: "92400e"))
            Text("どんなに小さな一歩でも、着実に目標へ近づいています。明日も無理のないペースで進めていきましょう。")
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
