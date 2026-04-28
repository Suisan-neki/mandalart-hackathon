import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var displayedRate: Int = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.3
    @State private var navigateToJournal = false

    private var targetRate: Int { vm.todayCompletionRate }
    private var completedActions: Int { vm.todayCompletedCount }
    private var remainingActions: Int { max(vm.totalTaskCount - vm.todayCompletedCount, 0) }

    private var isHighRate:   Bool { targetRate >= 80 }
    private var isMediumRate: Bool { targetRate >= 60 && targetRate < 80 }

    private var theme: RateTheme {
        if isHighRate {
            return RateTheme(
                gradient: [Color(hex: "fff7ed"), Color(hex: "ffedd5")],
                ring: Color(hex: "fb923c").opacity(0.3),
                core: [Color(hex: "fb923c"), Color(hex: "f97316")],
                text: Color(hex: "d97706"),
                glow: Color(hex: "fb923c").opacity(0.2)
            )
        } else if isMediumRate {
            return RateTheme(
                gradient: [Color(hex: "eff6ff"), Color(hex: "eef2ff")],
                ring: Color(hex: "60a5fa").opacity(0.3),
                core: [Color(hex: "60a5fa"), Color(hex: "6366f1")],
                text: Color(hex: "2563eb"),
                glow: Color(hex: "60a5fa").opacity(0.2)
            )
        } else {
            return RateTheme(
                gradient: [Color(hex: "faf5ff"), Color(hex: "fdf2f8")],
                ring: Color(hex: "c084fc").opacity(0.3),
                core: [Color(hex: "c084fc"), Color(hex: "ec4899")],
                text: Color(hex: "9333ea"),
                glow: Color(hex: "c084fc").opacity(0.2)
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Achievement ring section
                achievementRingSection

                // Feedback message
                feedbackSection
                    .padding(.horizontal, 24)

                // Action breakdown
                actionBreakdownSection
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                // Cognitive gap insights
                cognitiveGapSection
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 60)
            }
        }
        .background(
            LinearGradient(colors: theme.gradient, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToJournal) {
            SyncJournalView()
        }

        .onAppear {
            animateRate()
            triggerGapPresentationIfNeeded()
        }
    }

    // MARK: - Achievement Ring
    private var achievementRingSection: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 70)

            ZStack {
                // Pulsing glow
                Circle()
                    .fill(theme.glow)
                    .frame(width: 256, height: 256)
                    .blur(radius: 60)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)

                // Outer ring
                Circle()
                    .stroke(theme.ring, lineWidth: 1)
                    .frame(width: 296, height: 296)
                    .scaleEffect(pulseScale * 0.97)
                    .opacity(pulseOpacity * 1.5)

                // Middle ring
                Circle()
                    .stroke(theme.ring, lineWidth: 1)
                    .frame(width: 272, height: 272)
                    .scaleEffect(pulseScale * 0.98)
                    .opacity(pulseOpacity)

                // Main circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 240, height: 240)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 30, y: 10)
                    .overlay {
                        VStack(spacing: 4) {
                            Text("今日の完了率")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.stone400)
                                .tracking(2)
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text("\(displayedRate)")
                                    .font(.system(size: 60, weight: .black, design: .rounded))
                                    .foregroundColor(theme.text)
                                Text("%")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.stone300)
                            }
                            // Stats row
                            HStack(spacing: 16) {
                                statItem(label: "完了", value: "\(completedActions)", unit: "項目")
                                Rectangle()
                                    .fill(Color.stone200)
                                    .frame(width: 1, height: 28)
                                statItem(label: "全体", value: "\(vm.totalTaskCount)", unit: "項目")
                            }
                            .padding(.top, 8)
                        }
                    }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseScale   = 1.15
                pulseOpacity = 0.6
            }
        }
    }

    private func statItem(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color.stone400)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(Color.stone700)
                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color.stone400)
            }
        }
    }

    // MARK: - Feedback
    private var feedbackSection: some View {
        VStack(spacing: 14) {
            if isHighRate {
                Text("今日もやりきった")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color.stone800)
                Text("目標に向けた行動が記録にちゃんと残っている。この積み重ねが一番大事。")
                    .font(.system(size: 14))
                    .foregroundColor(Color.stone500)
                    .lineSpacing(5)
            } else if isMediumRate {
                Text("いいペースで進んでいる")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color.stone800)
                Text("全部できなくても問題ない。動いた分だけ前に進んでいる。")
                    .font(.system(size: 14))
                    .foregroundColor(Color.stone500)
                    .lineSpacing(5)
            } else {
                Text("まず1つ動かしてみよう")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color.stone800)
                Text("記録が少ない日もある。明日は32個の中から1つだけ選んで、それだけやってみる。")
                    .font(.system(size: 14))
                    .foregroundColor(Color.stone500)
                    .lineSpacing(5)

                // Advice card
                VStack(alignment: .leading, spacing: 8) {
                    Label("1つだけ選ぶ", systemImage: "scope")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.stone800)
                    Text("全部やろうとしなくていい。今日の自分が一番やれそうなアクションを1つ選んで、それだけ動く。")
                        .font(.system(size: 12))
                        .foregroundColor(Color.stone600)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 0.5)
                )
            }
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Action Breakdown
    private var actionBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { navigateToJournal = true }) {
                HStack {
                    Label("今日の行動", systemImage: "waveform.path.ecg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.stone800)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundColor(Color.stone400)
                }
            }

            summaryCard(
                iconName: "checkmark.circle.fill",
                iconBg: Color(hex: "dcfce7"),
                iconColor: Color(hex: "16a34a"),
                badge: "Action",
                title: "実行できたアクション",
                count: "\(completedActions)",
                unit: "項目"
            )

            summaryCard(
                iconName: "arrow.up.right",
                iconBg: Color(hex: "f3e8ff"),
                iconColor: Color(hex: "9333ea"),
                badge: "To Do",
                title: "これからのアクション",
                count: "\(remainingActions)",
                unit: "項目"
            )
        }
    }

    private func summaryCard(iconName: String, iconBg: Color, iconColor: Color, badge: String, title: String, count: String, unit: String) -> some View {
        HStack {
            ZStack {
                Circle().fill(iconBg).frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(badge)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.stone400)
                    .tracking(1)
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.stone800)
            }
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(count)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color.stone800)
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(Color.stone400)
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.stone100))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }

    // MARK: - Cognitive Gap Insights
    private var cognitiveGapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("GitHub 連携分析", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.stone800)
                Spacer()
                Text("\(vm.cognitiveGapScore)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color.red600)
                Text("/100")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.stone400)
            }

            if vm.topGapInsights.isEmpty {
                insightCard(
                    iconName: "checkmark.seal.fill",
                    iconBg: Color(hex: "dcfce7"),
                    iconColor: Color(hex: "16a34a"),
                    title: "GitHub との対応は見つかりません",
                    subtitle: "GitHub を連携して同期すると、ここに分析が表示されます。"
                )
            } else {
                ForEach(vm.topGapInsights) { insight in
                    insightCard(
                        iconName: iconName(for: insight.severity),
                        iconBg: backgroundColor(for: insight.severity),
                        iconColor: foregroundColor(for: insight.severity),
                        title: insight.blockTitle,
                        subtitle: insight.summary
                    )
                }
            }

            if let top = vm.mostCriticalGap {
                VStack(alignment: .leading, spacing: 6) {
                    Text("次の一手")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.stone500)
                        .tracking(1)
                    Text(top.recommendation)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.stone700)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.stone100))

            }
        }
    }

    private func insightCard(iconName: String, iconBg: Color, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(iconBg).frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 17))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.stone800)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.stone500)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.stone100))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }

    private func iconName(for severity: CognitiveGapSeverity) -> String {
        switch severity {
        case .aligned:
            return "checkmark.seal.fill"
        case .caution:
            return "exclamationmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "eye.trianglebadge.exclamationmark.fill"
        }
    }

    private func backgroundColor(for severity: CognitiveGapSeverity) -> Color {
        switch severity {
        case .aligned:
            return Color(hex: "dcfce7")
        case .caution:
            return Color(hex: "fef3c7")
        case .warning:
            return Color(hex: "fee2e2")
        case .critical:
            return Color(hex: "ede9fe")
        }
    }

    private func foregroundColor(for severity: CognitiveGapSeverity) -> Color {
        switch severity {
        case .aligned:
            return Color(hex: "16a34a")
        case .caution:
            return Color(hex: "d97706")
        case .warning:
            return Color(hex: "dc2626")
        case .critical:
            return Color(hex: "6d28d9")
        }
    }

    private func triggerGapPresentationIfNeeded() {
        guard let gap = vm.mostCriticalGap else { return }
        guard gap.severity.rank >= CognitiveGapSeverity.warning.rank else { return }

        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            pulseScale = gap.severity == .critical ? 1.2 : 1.16
            pulseOpacity = gap.severity == .critical ? 0.75 : 0.65
        }
    }

    // MARK: - Animate rate counter
    private func animateRate() {
        let steps = 60
        let duration: Double = 2.0
        let interval = duration / Double(steps)
        let increment = Double(targetRate) / Double(steps)
        var current: Double = 0
        var step = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            step += 1
            current += increment
            if step >= steps {
                displayedRate = targetRate
                timer.invalidate()
            } else {
                displayedRate = Int(current)
            }
        }
    }
}

struct RateTheme {
    let gradient: [Color]
    let ring: Color
    let core: [Color]
    let text: Color
    let glow: Color
}

#Preview {
    NavigationStack {
        ResultView()
    }
    .environmentObject(AppViewModel())
}
