import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var showSplash = true
    /// 初回起動時（isFirstLaunch）はオンボーディング、
    /// 2回目以降は LaunchTutorialView を1度だけ表示する。
    @State private var showLaunchTutorial = false

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if vm.isFirstLaunch {
                OnboardingView()
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
        .animation(.easeInOut(duration: 0.4), value: vm.isFirstLaunch)
        .animation(.easeInOut(duration: 0.4), value: showLaunchTutorial)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                    // 初回起動でなければ LaunchTutorialView を表示
                    if !vm.isFirstLaunch {
                        showLaunchTutorial = true
                    }
                }
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

