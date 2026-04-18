import SwiftUI

struct DailyCheckinView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: AppViewModel
    @State private var tasks: [DailyTask] = []
    @State private var totalCount = 0
    @State private var navigateToResult = false

    private var completedCount: Int { totalCount - tasks.count }
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if tasks.isEmpty {
                    completionView
                } else {
                    checkinContent
                }
            }
            .background(Color.stone50.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToResult) {
                ResultView()
            }
            .onAppear {
                if totalCount == 0 {
                    let pending = vm.pendingDailyTasks
                    tasks = pending.reversed()
                    totalCount = vm.totalTaskCount
                }
            }
        }
    }

    // MARK: - Checkin Content
    private var checkinContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18))
                        .foregroundColor(Color.stone800)
                        .padding(8)
                        .background(Color.stone200.opacity(0.6))
                        .clipShape(Circle())
                }
                Spacer()
                Label("デイリーチェックイン", systemImage: "scope")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.stone800)
                Spacer()
                Text("\(completedCount + 1)/\(totalCount)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.stone400)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.stone200)
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.red600)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // Card stack
            ZStack {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    let isTop = index == tasks.count - 1
                    let isSecond = index == tasks.count - 2

                    if isTop || isSecond {
                        SwipeableCard(
                            task: task,
                            isTop: isTop,
                            onSwipe: { didComplete in
                                handleAnswer(didComplete ? .completed : .skipped)
                            }
                        )
                        .scaleEffect(isTop ? 1 : 0.95)
                        .offset(y: isTop ? 0 : 20)
                        .zIndex(isTop ? 1 : 0)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)

            // Button row
            HStack(spacing: 40) {
                actionButton(systemImage: "xmark", color: Color.stone400, highlightColor: Color.red500) {
                    handleAnswer(.skipped)
                }
                actionButton(systemImage: "checkmark", color: Color(hex: "22c55e"), highlightColor: Color(hex: "16a34a")) {
                    handleAnswer(.completed)
                }
            }
            .padding(.bottom, 48)
        }
    }

    private func handleAnswer(_ answer: CheckinAnswer) {
        guard let task = tasks.last else { return }

        vm.recordCheckin(task: task, answer: answer)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            _ = tasks.popLast()
        }
    }

    private func actionButton(systemImage: String, color: Color, highlightColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 64, height: 64)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                .overlay(Circle().stroke(Color.stone200, lineWidth: 0.5))
        }
    }

    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(hex: "fef3c7").opacity(0.5))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color.amber500)
            }
            VStack(spacing: 8) {
                Text("チェックイン完了")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color.stone800)
                Text("今日の振り返りを記録しました。\n完了 \(vm.todayCompletedCount) 件 / 全 \(vm.totalTaskCount) 件")
                    .font(.system(size: 13))
                    .foregroundColor(Color.stone500)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            Spacer()
            Button(action: { navigateToResult = true }) {
                Label("同期結果を見る", systemImage: "bolt.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.amber500)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.amber500.opacity(0.3), radius: 12, y: 4)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 48)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - Swipeable Card
struct SwipeableCard: View {
    let task: DailyTask
    let isTop: Bool
    let onSwipe: (Bool) -> Void

    @State private var offset: CGSize = .zero
    @GestureState private var isDragging = false

    private var rotation: Double { Double(offset.width) / 20 }
    private var swipeProgress: Double {
        min(Double(abs(offset.width) / 150.0), 1.0)
    }
    private var cardBg: Color {
        if offset.width > 30 {
            return Color(hex: "dcfce7").interpolated(to: .white, by: 1 - swipeProgress * 0.8)
        } else if offset.width < -30 {
            return Color(hex: "fee2e2").interpolated(to: .white, by: 1 - swipeProgress * 0.8)
        }
        return .white
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(task.theme.border, lineWidth: isTop ? 1.5 : 0)
                )
                .shadow(color: .black.opacity(0.1), radius: 24, y: 8)

            VStack(alignment: .leading, spacing: 0) {
                // Category tag
                Text(task.category)
                    .font(.system(size: 11, weight: .black))
                    .tracking(1)
                    .foregroundColor(task.theme.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(task.theme.light)
                    .clipShape(Capsule())
                    .padding(.bottom, 24)

                Spacer()

                Text(task.title)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Color.stone900)
                    .lineSpacing(4)

                Text("今日、この目標に向かって実際に行動しましたか？")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.stone500)
                    .padding(.top, 12)
                    .lineSpacing(3)

                Spacer()

                // Swipe hints
                HStack {
                    Label("NO", systemImage: "xmark")
                    Spacer()
                    Label("YES", systemImage: "checkmark")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.stone300)
                .opacity(0.6)
            }
            .padding(32)
        }
        .frame(maxWidth: 320)
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(
            isTop ? DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    if abs(value.translation.width) > 120 {
                        let isRight = value.translation.width > 0
                        withAnimation(.spring(response: 0.3)) {
                            offset = CGSize(width: isRight ? 500 : -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipe(isRight)
                        }
                    } else {
                        withAnimation(.spring()) { offset = .zero }
                    }
                } : nil
        )
        .animation(.spring(response: 0.3), value: offset)
    }
}

// MARK: - Color interpolation helper
extension Color {
    func interpolated(to other: Color, by factor: Double) -> Color {
        let clamped = min(max(factor, 0), 1)
        let from = UIColor(self)
        let to = UIColor(other)

        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0

        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        return Color(
            .sRGB,
            red: Double(fromRed + (toRed - fromRed) * clamped),
            green: Double(fromGreen + (toGreen - fromGreen) * clamped),
            blue: Double(fromBlue + (toBlue - fromBlue) * clamped),
            opacity: Double(fromAlpha + (toAlpha - fromAlpha) * clamped)
        )
    }
}

#Preview {
    DailyCheckinView()
        .environmentObject(AppViewModel())
}
