import AudioToolbox
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var progressWidth: CGFloat = 0
    @State private var navigateToCheckin = false
    @State private var navigateToJournal = false
    @State private var navigateToResult = false
    @State private var navigateToSettings = false
    @State private var bannerPulse = false
    @State private var warningShake: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Dark header
                headerSection

                // Offline banner
                if vm.isOffline {
                    offlineBanner
                }

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
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView()
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView()
        }
        .alert(
            "同期エラー",
            isPresented: Binding(
                get: { vm.syncErrorMessage != nil },
                set: { if !$0 { vm.syncErrorMessage = nil; vm.syncRequiresSettings = false } }
            )
        ) {
            if vm.syncRequiresSettings {
                Button("設定を開く") {
                    vm.syncErrorMessage = nil
                    vm.syncRequiresSettings = false
                    navigateToSettings = true
                }
            }
            Button("閉じる", role: .cancel) {}
        } message: {
            Text(vm.syncErrorMessage ?? "")
        }
        .onAppear {
            startWarningAnimationIfNeeded()
        }
        .onChange(of: vm.mostCriticalGap?.id) { _, _ in
            startWarningAnimationIfNeeded()
        }
    }

    // MARK: - Offline Banner
    private var offlineBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text("オフラインです。同期は接続後に実行されます。")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.orange500)
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
                        Label("全体の進捗", systemImage: "waveform.path.ecg")
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
            Label("今日の記録", systemImage: "checkmark.circle.fill")
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

                Text("32項目の目標にどう近づいたかを記録しましょう。小さな一歩も大切な積み上げです。")
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
                    icon: "square.grid.3x3.fill",
                    title: "マンダラートを見る",
                    subtitle: "アクションの進捗や内容を確認・編集する"
                ) {
                    // 目標タブに切り替えるのはタブバーから操作するため、ここは空実装のまま
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
        Button(action: { navigateToResult = true }) {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.indigo600)
                    .padding(8)
                    .background(Color.indigo600.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("目標と行動を照らし合わせてみましょう")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "312e81"))
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundColor(Color.indigo400)
                    }
                    Text(vm.mostCriticalGap?.summary ?? "1ヶ月が経過しました。現在の目標は今のあなたにフィットしていますか？")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "4338ca").opacity(0.8))
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(bannerBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24).stroke(bannerStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(bannerPulse ? 1.01 : 0.985)
        .shadow(color: bannerShadow, radius: bannerPulse ? 22 : 8, y: 4)
        .offset(x: warningShake)
        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: bannerPulse)
    }

    private var bannerBackground: LinearGradient {
        if vm.mostCriticalGap?.severity == .critical {
            return LinearGradient(
                colors: [Color(hex: "f5d0fe"), Color(hex: "fee2e2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color.indigo100, Color(hex: "e9d5ff")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var bannerStroke: Color {
        vm.mostCriticalGap?.severity == .critical ? Color.red500.opacity(0.35) : Color.indigo100
    }

    private var bannerShadow: Color {
        vm.mostCriticalGap?.severity == .critical
            ? Color.red500.opacity(vm.intenseEffectsEnabled ? 0.28 : 0.12)
            : Color.indigo400.opacity(0.12)
    }

    private func startWarningAnimationIfNeeded() {
        guard let gap = vm.mostCriticalGap else { return }

        bannerPulse = true

        guard vm.intenseEffectsEnabled, gap.severity.rank >= CognitiveGapSeverity.warning.rank else { return }

        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(gap.severity == .critical ? .error : .warning)
        AudioServicesPlaySystemSound(1006)

        withAnimation(.easeInOut(duration: 0.08)) { warningShake = -10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.08)) { warningShake = 8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { warningShake = 0 }
        }
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
