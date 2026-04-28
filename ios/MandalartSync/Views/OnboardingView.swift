import SwiftUI

/// 初回起動時に表示するオンボーディング画面。
/// 目標（mainGoal）を入力して、8つのカテゴリ名を設定する。
struct OnboardingView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var step: Int = 0
    @State private var goalText: String = ""
    @State private var categoryTitles: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedField: Int?

    private let defaultCategoryTitles = [
        "技術力", "発信力", "健康", "マインドセット"
    ]

    var body: some View {
        ZStack {
            Color.stone50.ignoresSafeArea()

            VStack(spacing: 0) {
                // プログレスバー
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.stone200)
                            .frame(height: 3)
                        Rectangle()
                            .fill(Color.indigo600)
                            .frame(width: geo.size.width * (step == 0 ? 0.5 : 1.0), height: 3)
                            .animation(.easeInOut(duration: 0.4), value: step)
                    }
                }
                .frame(height: 3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if step == 0 {
                            goalInputStep
                        } else {
                            categoryInputStep
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                }

                // 次へ / 始めるボタン
                VStack(spacing: 0) {
                    Divider()
                    Button(action: handleNext) {
                        Text(step == 0 ? "次へ" : "始める")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canProceed ? Color.indigo600 : Color.stone300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canProceed)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .background(.white)
            }
        }
    }

    // MARK: - Step 0: 目標入力

    private var goalInputStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("あなたの目標を\n教えてください")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.stone900)
                    .lineSpacing(4)

                Text("マンダラートの中心に置く、一番大切な目標です。")
                    .font(.system(size: 14))
                    .foregroundColor(Color.stone500)
            }

            VStack(alignment: .leading, spacing: 8) {
                TextField("例：技育CAMPで優勝する", text: $goalText)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(goalText.isEmpty ? Color.stone200 : Color.indigo600, lineWidth: 1.5)
                    )
                    .focused($focusedField, equals: 0)
                    .onAppear { focusedField = 0 }

                Text("後から変更できます")
                    .font(.system(size: 11))
                    .foregroundColor(Color.stone400)
                    .padding(.leading, 4)
            }
        }
    }

    // MARK: - Step 1: カテゴリ入力

    private var categoryInputStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("目標を支える\n4つの柱を決めましょう")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.stone900)
                    .lineSpacing(4)

                Text("それぞれの柱に8つのアクションが紐づきます。空欄はデフォルト名を使います。")
                    .font(.system(size: 14))
                    .foregroundColor(Color.stone500)
                    .lineSpacing(3)
            }

            VStack(spacing: 12) {
                ForEach(0..<4) { i in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(categoryColor(i).primary)
                            .frame(width: 10, height: 10)

                        TextField(defaultCategoryTitles[i], text: $categoryTitles[i])
                            .font(.system(size: 15))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.stone200, lineWidth: 1)
                            )
                            .focused($focusedField, equals: i + 1)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var canProceed: Bool {
        if step == 0 { return !goalText.trimmingCharacters(in: .whitespaces).isEmpty }
        return true
    }

    private func handleNext() {
        if step == 0 {
            withAnimation { step = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { focusedField = 1 }
        } else {
            applyOnboarding()
        }
    }

    private func applyOnboarding() {
        let goal = goalText.trimmingCharacters(in: .whitespaces)
        let colors: [CategoryColor] = [.blue, .orange, .green, .purple]
        let categories: [MandalartCategory] = (0..<4).map { i in
            let title = categoryTitles[i].trimmingCharacters(in: .whitespaces).isEmpty
                ? defaultCategoryTitles[i]
                : categoryTitles[i]
            let baseId = (i + 1) * 100
            let blocks: [MandalartBlock] = (1...8).map { j in
                MandalartBlock(id: baseId + j, title: "", progress: 0, resonance: 50, cleared: false)
            }
            return MandalartCategory(id: i + 1, title: title, color: colors[i], blocks: blocks)
        }
        vm.mainGoal = goal
        vm.categories = categories
        vm.journalEntries = []
        vm.gapInsights = []
    }

    private func categoryColor(_ index: Int) -> CategoryColor {
        [CategoryColor.blue, .orange, .green, .purple][index]
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}
