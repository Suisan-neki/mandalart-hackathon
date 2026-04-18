import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var progressWidth: CGFloat = 0
    @State private var navigateToCheckin = false
    @State private var navigateToJournal = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Dark header
                headerSection

                // Content
                VStack(spacing: 24) {
                    todaySection
                    quickActionsSection
                    goalReviewBanner
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
            }
        }
        .background(Color.stone50.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToCheckin) {
            DailyCheckinView()
        }
        .navigationDestination(isPresented: $navigateToJournal) {
            SyncJournalView()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            Color.zinc950

            // Glow
            Circle()
                .fill(Color.indigo600.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: UIScreen.main.bounds.width - 60, y: -30)

            VStack(alignment: .leading, spacing: 16) {
                // Top row: goal + action buttons
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("あなたの目標")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.zinc400)
                            .tracking(2)
                        Text(vm.mainGoal)
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Button(action: { vm.triggerSync() }) {
                            Image(systemName: vm.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                                .font(.system(size: 14))
                                .foregroundColor(Color.zinc400)
                                .padding(8)
                                .background(Color.zinc800)
                                .clipShape(Circle())
                        }
                        .rotationEffect(.degrees(vm.isSyncing ? 360 : 0))
                        .animation(
                            vm.isSyncing
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                            value: vm.isSyncing
                        )
                    }
                    .padding(6)
                    .background(Color.zinc900.opacity(0.8))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.zinc800))
                }

                // Progress card
                progressCard
            }
            .padding(.top, 60)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
        // Bottom rounded corners
        .overlay(alignment: .bottom) {
            RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight])
                .fill(Color.zinc950)
                .frame(height: 40)
                .offset(y: 20)
        }
    }

    private var progressCard: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.zinc900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24).stroke(Color.zinc800, lineWidth: 0.5)
                    )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("今週の実行率", systemImage: "waveform.path.ecg")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.zinc300)
                        Spacer()
                        Text("\(Int(vm.weeklyProgress))%")
                            .font(.system(size: 26, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.zinc800)
                                .frame(height: 6)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.indigo600, Color.indigo400],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: progressWidth, height: 6)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 1.0)) {
                                        progressWidth = geo.size.width * CGFloat(vm.weeklyProgress / 100)
                                    }
                                }
                        }
                    }
                    .frame(height: 6)
                }
                .padding(20)
            }
        }
    }

    // MARK: - Today Section
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("今日やるべきこと", systemImage: "checkmark.circle.fill")
                .font(.system(size: 17, weight: .black))
                .foregroundColor(Color.stone900)

            Button(action: { navigateToCheckin = true }) {
                checkinCard
            }
            .buttonStyle(.plain)
        }
    }

    private var checkinCard: some View {
        ZStack(alignment: .topTrailing) {
            // Glow
            Circle()
                .fill(Color.indigo100.opacity(0.5))
                .frame(width: 120)
                .blur(radius: 30)
                .offset(x: 10, y: -10)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "scope")
                        .font(.system(size: 22))
                        .foregroundColor(Color.indigo600)
                        .padding(10)
                        .background(Color.indigo100)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Spacer()
                    Text("残り \(vm.pendingDailyTasks.count) 件")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.indigo600)
                        .clipShape(Capsule())
                        .tracking(1)
                }

                Text("今日できたことを記録する")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color.stone900)

                Text("今日の行動を振り返り、32項目の目標にどう近づいたかを記録しましょう。小さな一歩も大切な積み上げです。")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.stone500)
                    .lineSpacing(4)

                HStack {
                    Text("振り返りをスタート")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.indigo600)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.indigo600)
                        .padding(8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.06), radius: 4)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.stone100)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(20)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28).stroke(Color.stone200, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("便利な機能")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.stone400)
                .tracking(2)

            HStack(spacing: 14) {
                quickActionTile(
                    icon: "list.bullet.rectangle",
                    title: "できたことの記録",
                    subtitle: "過去の行動ログ（タイムライン）を見る"
                ) {
                    navigateToJournal = true
                }
                quickActionTile(
                    icon: "plus.circle.fill",
                    title: "アクション追加",
                    subtitle: "マンダラートに新しい目標を追加する"
                ) {
                    // navigate to action editor
                }
            }
        }
    }

    private func quickActionTile(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.stone600)
                    .padding(10)
                    .background(Color.stone100)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.stone800)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.stone500)
                        .lineLimit(2)
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24).stroke(Color.stone200, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Goal Review Banner
    private var goalReviewBanner: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.indigo600)
                    .padding(8)
                    .background(Color.indigo600.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("目標を見直す時期かも？")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "312e81"))
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundColor(Color.indigo400)
                    }
                    Text("1ヶ月が経過しました。現在の目標は今のあなたにフィットしていますか？")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "4338ca").opacity(0.8))
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.indigo100)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24).stroke(Color.indigo100, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rounded Corner Helper
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(AppViewModel())
}
