import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var showSplash = true
    @State private var showLaunchTutorial = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if showLaunchTutorial {
                LaunchTutorialView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showLaunchTutorial = false
                    }
                }
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: showLaunchTutorial)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}

struct LaunchTutorialView: View {
    let onFinish: () -> Void
    @State private var index = 0

    private let slides: [LaunchTutorialSlide] = [
        LaunchTutorialSlide(
            systemImageName: "square.grid.3x3.fill",
            title: "マンダラートの力",
            subtitle: "思考を整理し、夢を現実にする",
            description: "マンダラートとは、目標達成のための思考整理ツールです。大谷翔平選手も高校時代に活用したことで知られています。",
            themeColor: Color(hex: "60a5fa")
        ),
        LaunchTutorialSlide(
            systemImageName: "target",
            title: "中心に目標を置く",
            subtitle: "まずは一番大切なゴールから",
            description: "中心の目標からテーマを広げ、小さなアクションに分解します。大きな夢も、今日やることまで落とし込めます。",
            themeColor: Color.indigo600
        ),
        LaunchTutorialSlide(
            systemImageName: "checkmark.seal.fill",
            title: "毎日の行動を積み上げる",
            subtitle: "記録と連携で進捗が見える",
            description: "手動記録に加えて、GitHubのコミット数やCalendarの予定も行動ログとして確認できます。",
            themeColor: Color.amber500
        )
    ]

    private var slide: LaunchTutorialSlide { slides[index] }

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.height < 720

            ZStack {
                Color.zinc950.ignoresSafeArea()

                VStack(spacing: isCompact ? 18 : 28) {
                    Spacer(minLength: isCompact ? 18 : 40)

                    ZStack {
                        Circle()
                            .fill(slide.themeColor.opacity(0.18))
                            .frame(width: isCompact ? 132 : 168, height: isCompact ? 132 : 168)
                            .blur(radius: 2)

                        Image(systemName: slide.systemImageName)
                            .font(.system(size: isCompact ? 58 : 74, weight: .black))
                            .foregroundColor(slide.themeColor)
                    }

                    VStack(spacing: isCompact ? 8 : 12) {
                        Text(slide.title)
                            .font(.system(size: isCompact ? 28 : 34, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)

                        Text(slide.subtitle)
                            .font(.system(size: isCompact ? 15 : 17, weight: .bold))
                            .foregroundColor(slide.themeColor)
                            .multilineTextAlignment(.center)

                        Text(slide.description)
                            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                            .foregroundColor(Color.zinc300)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .lineLimit(isCompact ? 4 : 5)
                            .minimumScaleFactor(0.85)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 28)

                    HStack(spacing: 8) {
                        ForEach(slides.indices, id: \.self) { i in
                            Capsule()
                                .fill(i == index ? slide.themeColor : Color.zinc700)
                                .frame(width: i == index ? 24 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.25), value: index)
                        }
                    }
                    .padding(.top, isCompact ? 2 : 8)

                    Spacer(minLength: isCompact ? 16 : 36)

                    VStack(spacing: 12) {
                        Button(action: advance) {
                            Text(index == slides.count - 1 ? "はじめる" : "次へ")
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(Color.zinc950)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(slide.themeColor)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }

                        Button(action: onFinish) {
                            Text("スキップ")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.zinc400)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, isCompact ? 18 : 32)
                }
            }
        }
    }

    private func advance() {
        if index < slides.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                index += 1
            }
        } else {
            onFinish()
        }
    }
}

private struct LaunchTutorialSlide {
    let systemImageName: String
    let title: String
    let subtitle: String
    let description: String
    let themeColor: Color
}

struct MandalartInputTutorialView: View {
    let onFinish: () -> Void
    @State private var index = 0

    private let steps: [MandalartInputTutorialStep] = [
        MandalartInputTutorialStep(
            title: "大目標を入力する",
            description: "まず中心に置く一番大きな目標を決めます。ここがマンダラート全体の軸になります。",
            focus: .mainGoal
        ),
        MandalartInputTutorialStep(
            title: "中目標を4つ入力する",
            description: "大目標を支える4つのテーマを置きます。技術、健康、人間関係など、自分に必要な柱へ分けます。",
            focus: .middleGoals
        ),
        MandalartInputTutorialStep(
            title: "小目標を穴埋めする",
            description: "まずは一番上の中目標から、小さな行動を8個入れていきます。空いているスポットを1つずつ埋めるイメージです。",
            focus: .smallGoals
        )
    ]

    private var step: MandalartInputTutorialStep { steps[index] }

    var body: some View {
        ZStack {
            blankMandalartScreen
                .overlay(Color.black.opacity(0.58).ignoresSafeArea())

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onFinish) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)

                spotlightOverlay

                Spacer()

                HStack(spacing: 8) {
                    ForEach(steps.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == index ? Color.green : Color.white.opacity(0.32))
                            .frame(width: i == index ? 24 : 8, height: 8)
                    }
                }
                .padding(.bottom, 14)

                Button(action: advance) {
                    Text(index == steps.count - 1 ? "わかった" : "次へ")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 30)
            }
        }
    }

    private var blankMandalartScreen: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 36) {
                    emptyGoalHeader(isHighlighted: false)

                    ForEach(0..<4, id: \.self) { index in
                        emptyCategoryGrid(index: index, isHighlighted: false)
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 120)
            }
        }
    }

    private var spotlightOverlay: some View {
        VStack(spacing: 12) {
            switch step.focus {
            case .mainGoal:
                Spacer().frame(height: 46)
                emptyGoalHeader(isHighlighted: true)
                    .padding(.horizontal, 20)
                tooltip(isLeading: false)
                    .padding(.horizontal, 24)
            case .middleGoals:
                Spacer().frame(height: 206)
                VStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        emptyCategoryGrid(index: index, isHighlighted: true)
                    }
                }
                .frame(maxHeight: 420)
                .clipped()
                .padding(.horizontal, 24)
                tooltip(isLeading: false)
                    .padding(.horizontal, 24)
            case .smallGoals:
                Spacer().frame(height: 206)
                emptyCategoryGrid(index: 0, isHighlighted: true, focusSmallGoals: true)
                    .frame(maxWidth: 210)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                tooltip(isLeading: true)
                    .frame(maxWidth: 270)
                    .padding(.leading, 42)
            }
        }
    }

    private func tooltip(isLeading: Bool) -> some View {
        VStack(alignment: isLeading ? .leading : .center, spacing: 0) {
            Triangle()
                .fill(Color.green)
                .frame(width: 24, height: 14)
                .padding(.leading, isLeading ? 20 : 0)

            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Text(step.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func emptyGoalHeader(isHighlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("中心の目標")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Color.zinc500)
                    .tracking(2)

                Text("タップして目標を入力")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(22)
            .background(Color.zinc900)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(isHighlighted ? Color.green : Color.zinc800, lineWidth: isHighlighted ? 3 : 0.5)
            )
            .shadow(color: isHighlighted ? Color.green.opacity(0.6) : .clear, radius: 16)

            HStack(spacing: 20) {
                legendItem(color: Color.zinc800, label: "未着手")
                legendItem(color: .white, label: "継続中")
                legendItem(color: Color(hex: "facc15"), label: "クリア済")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isHighlighted ? 0 : 1)
        }
    }

    private func emptyCategoryGrid(index: Int, isHighlighted: Bool, focusSmallGoals: Bool = false) -> some View {
        let colors: [CategoryColor] = [.blue, .orange, .green, .purple]
        let color = colors[index]

        return VStack(spacing: 12) {
            Text("テーマを入力")
                .font(.system(size: 17, weight: .black))
                .foregroundColor(Color.zinc300)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9, id: \.self) { cell in
                    if cell == 4 {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.zinc800, lineWidth: 0.5)
                                )
                            Text("テーマを入力")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(6)
                        }
                    } else {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(color.primary)
                                .overlay(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 8)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(focusSmallGoals ? Color.green : color.border, lineWidth: focusSmallGoals ? 2 : 0.5)
                                )

                            Text("タップして入力")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white.opacity(0.72))
                                .lineLimit(3)
                                .minimumScaleFactor(0.75)
                                .padding(7)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isHighlighted ? Color.green : .clear, lineWidth: isHighlighted && !focusSmallGoals ? 3 : 0)
                .padding(.horizontal, 6)
        )
        .shadow(color: isHighlighted ? Color.green.opacity(0.5) : .clear, radius: 14)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.zinc400)
        }
    }

    private func advance() {
        if index < steps.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                index += 1
            }
        } else {
            onFinish()
        }
    }
}

private struct MandalartInputTutorialStep {
    let title: String
    let description: String
    let focus: MandalartInputFocus
}

private enum MandalartInputFocus {
    case mainGoal
    case middleGoals
    case smallGoals
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
