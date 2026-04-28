import SwiftUI

struct BlockMandalartView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedBlock: SelectedBlock? = nil
    @State private var editingCategory: SelectedCategory? = nil
    @State private var isEditingMainGoal = false
    @Namespace private var ns
    // スポットライトチュートリアル
    @State private var tutorialStep: Int? = nil
    @State private var screenSize: CGSize = .zero

    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 36) {
                    goalHeader

                    ForEach(vm.categories) { category in
                        CategoryGridView(
                            category: category,
                            namespace: ns,
                            onCategoryTap: {
                                editingCategory = SelectedCategory(
                                    categoryId: category.id,
                                    title: category.title,
                                    color: category.color
                                )
                            },
                            onTap: { block in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selectedBlock = SelectedBlock(block: block, categoryId: category.id, color: category.color)
                                }
                            }
                        )
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 120)
            }

            // Screen size tracker
            GeometryReader { geo in
                Color.clear
                    .onAppear { screenSize = geo.size }
                    .onChange(of: geo.size) { screenSize = $0 }
            }
            .ignoresSafeArea()

            // Block detail overlay
            if let sel = selectedBlock {
                blockDetailOverlay(sel)
            }

            // Spotlight tutorial overlay
            if let step = tutorialStep {
                spotlightOverlay(step: step)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.zinc950, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isEditingMainGoal) {
            MainGoalEditorView(title: vm.mainGoal) { title in
                vm.mainGoal = title
            }
            .presentationDetents([.height(220)])
        }
        .sheet(item: $editingCategory) { category in
            CategoryTitleEditorView(category: category) { title in
                vm.updateCategoryTitle(categoryId: category.categoryId, title: title)
            }
            .presentationDetents([.height(220)])
        }
    }

    private var goalHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button {
                isEditingMainGoal = true
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("中心の目標")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Color.zinc500)
                        .tracking(2)

                    Text(vm.mainGoal.isEmpty ? "タップして目標を入力" : vm.mainGoal)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(22)
                .background(Color.zinc900)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.zinc800, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 20) {
                legendItem(color: Color.zinc800, label: "未着手")
                legendItem(color: .white, label: "継続中")
                legendItem(color: Color(hex: "facc15"), label: "クリア済", glow: true)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Block Detail Overlay
    @ViewBuilder
    private func blockDetailOverlay(_ sel: SelectedBlock) -> some View {
        Color.black.opacity(0.6)
            .ignoresSafeArea()
            .blur(radius: 4)
            .onTapGesture {
                withAnimation(.spring()) { selectedBlock = nil }
            }

        BlockDetailView(
            sel: sel,
            namespace: ns,
            onDismiss: {
                withAnimation(.spring()) { selectedBlock = nil }
            }
        )
        .environmentObject(vm)
        .padding(.horizontal, 24)
    }

    // MARK: - Spotlight Tutorial
    @ViewBuilder
    private func spotlightOverlay(step: Int) -> some View {
        let totalSteps = 3
        let w = screenSize.width
        // グリッドの各セルサイズを計算
        // CategoryGridViewは .padding(.horizontal, 16) で内側にグリッドがあり、その内側にさらに padding(.horizontal, 16) あり
        let gridHPad: CGFloat = 16 + 16  // outer + inner
        let spacing: CGFloat = 8
        let cellW = (w - gridHPad * 2 - spacing * 2) / 3
        let cellH = cellW  // aspect 1:1
        // ナビゲーションバーの高さ（おおよそ）
        let navBarH: CGFloat = 44 + 47  // status bar + nav bar
        // VStack spacing 40、レジェンドの高さ（おおよそ 28pt）、padding top 16
        let legendH: CGFloat = 16 + 28 + 40  // paddingTop + legend + spacing
        // CategoryGridViewのタイトル高さ（font 17 + spacing 12）
        let catTitleH: CGFloat = 17 + 12
        // 最初のカテゴリグリッドのY座標（スクロールなし想定）
        let gridTopY = navBarH + legendH + catTitleH
        // 各セルのX座標（左から）
        let col0X = gridHPad
        let col1X = gridHPad + cellW + spacing
        // 各行のY座標
        let row0Y = gridTopY
        let row1Y = gridTopY + cellH + spacing
        // ステップごとのハイライト対象セルの座標
        // Step 0: 中心セル (index 4 = row1, col1)
        // Step 1 & 2: blocks[0] (index 0 = row0, col0)
        let highlightRect: CGRect = {
            switch step {
            case 0:  return CGRect(x: col1X, y: row1Y, width: cellW, height: cellH)
            default: return CGRect(x: col0X, y: row0Y, width: cellW, height: cellH)
            }
        }()
        let messages = [
            ("まず核となる目標を1つ決めましょう", "中央のセルに大目標を入力します。\nタップして編集できます。"),
            ("目標を支えるテーマを決めます", "周りの8マスに、目標を達成するための\nテーマや要素を入力します。"),
            ("各テーマをさらに8つの行動に分けます", "各テーマの周囲8マスに具体的な行動を入力します。\nGitHubキーワードを設定するとコミットが自動記録されます。")
        ]
        let (msgTitle, msgBody) = step < messages.count ? messages[step] : ("", "")
        let padding: CGFloat = 8
        let holeRect = highlightRect.insetBy(dx: -padding, dy: -padding)
        let cornerRadius: CGFloat = 18

        ZStack(alignment: .top) {
            // 暗幕 + 穴抜き
            Canvas { ctx, size in
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.72)))
                var hole = Path()
                hole.addRoundedRect(
                    in: holeRect,
                    cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
                )
                ctx.blendMode = .destinationOut
                ctx.fill(hole, with: .color(.white))
            }
            .compositingGroup()
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // ハイライト枚線
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: holeRect.width, height: holeRect.height)
                .position(x: holeRect.midX, y: holeRect.midY)
                .allowsHitTesting(false)

            // 吹き出し（ハイライトの下に表示）
            VStack(alignment: .leading, spacing: 6) {
                Text(msgTitle)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Text(msgBody)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.85))
                    .lineSpacing(4)
                HStack {
                    Spacer()
                    Text(step < totalSteps - 1 ? "タップして次へ" : "タップして閉じる")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "1c1917").opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 24)
            .offset(y: holeRect.maxY + 16)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                if step < totalSteps - 1 {
                    tutorialStep = step + 1
                } else {
                    tutorialStep = nil
                }
            }
        }
    }

    // MARK: - Legend Item
    private func legendItem(color: Color, label: String, glow: Bool = false) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)
                .shadow(color: glow ? Color(hex: "facc15").opacity(0.8) : .clear, radius: 6)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.zinc400)
        }
    }
}

// MARK: - Selected Block
struct SelectedBlock {
    let block: MandalartBlock
    let categoryId: Int
    let color: CategoryColor
}

struct SelectedCategory: Identifiable {
    let categoryId: Int
    let title: String
    let color: CategoryColor

    var id: Int { categoryId }
}

private enum LinkedServiceTemplate: String, Identifiable {
    case github
    case googleCalendar

    var id: String { rawValue }

    var title: String {
        switch self {
        case .github: return "GitHub"
        case .googleCalendar: return "Google Calendar"
        }
    }

    var iconName: String {
        switch self {
        case .github: return "chevron.left.forwardslash.chevron.right"
        case .googleCalendar: return "calendar"
        }
    }

    var tint: Color {
        switch self {
        case .github: return Color.zinc300
        case .googleCalendar: return Color(hex: "60a5fa")
        }
    }
}

// MARK: - Category Grid View
struct CategoryGridView: View {
    let category: MandalartCategory
    let namespace: Namespace.ID
    let onCategoryTap: () -> Void
    let onTap: (MandalartBlock) -> Void

    private var displayTitle: String {
        category.title.isEmpty ? "テーマを入力" : category.title
    }
    private var isPlaceholder: Bool {
        category.title.isEmpty
    }

    // Maps 8 blocks to a 3x3 grid (center = category label)
    private var gridOrder: [MandalartBlock?] {
        let b = category.blocks
        return [b[0], b[1], b[2], b[3], nil, b[4], b[5], b[6], b[7]]
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(displayTitle)
                .font(.system(size: 17, weight: .black))
                .foregroundColor(isPlaceholder ? Color.zinc300 : category.color.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .onTapGesture(perform: onCategoryTap)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(Array(gridOrder.enumerated()), id: \.offset) { index, block in
                    if let block = block {
                        BlockCell(block: block, color: category.color, namespace: namespace)
                            .onTapGesture { onTap(block) }
                    } else {
                        // Center: category label
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.zinc800, lineWidth: 0.5)
                                )
                            Text(displayTitle)
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(isPlaceholder ? .white : category.color.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(6)
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture(perform: onCategoryTap)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Block Cell (3D effect)
struct BlockCell: View {
    let block: MandalartBlock
    let color: CategoryColor
    let namespace: Namespace.ID

    private let maxExtrusion: CGFloat = 14

    private var extrusion: CGFloat {
        block.cleared ? maxExtrusion : max(2, CGFloat(block.progress / 100) * maxExtrusion)
    }

    private var activeColor: Color { block.cleared ? Color(hex: "facc15") : color.primary }
    private var activeDark: Color  { block.cleared ? Color(hex: "ca8a04") : color.dark }
    private var activeBorder: Color { block.cleared ? Color(hex: "fde047") : color.border }
    private var displayTitle: String {
        block.title.isEmpty ? "タップして入力" : block.title
    }
    private var starLevel: Int {
        min(3, max(0, Int((block.progress / 33.333).rounded())))
    }

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height

            ZStack(alignment: .bottom) {
                // Glow for cleared
                if block.cleared {
                    Circle()
                        .fill(Color(hex: "facc15").opacity(0.2))
                        .blur(radius: 20)
                        .offset(y: 6)
                }

                // Bottom / side wall
                RoundedRectangle(cornerRadius: 14)
                    .fill(activeDark)
                    .frame(height: h - maxExtrusion + extrusion)

                // Top face
                RoundedRectangle(cornerRadius: 14)
                    .fill(activeColor)
                    .overlay(alignment: .top) {
                        // Shine edge
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                    }
                    .overlay(alignment: .topLeading) {
                        Text(displayTitle)
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(block.title.isEmpty ? .white.opacity(0.72) : (block.cleared ? Color(hex: "78350f") : .white))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .allowsTightening(true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(7)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        starRow
                            .padding(5)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(activeBorder, lineWidth: 0.5)
                    )
                    .frame(height: h - maxExtrusion)
                    .offset(y: -extrusion)
                    .matchedGeometryEffect(id: "block-\(block.id)", in: namespace)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.top, CGFloat(maxExtrusion))
    }

    private var starRow: some View {
        HStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < starLevel ? "star.fill" : "star")
                    .font(.system(size: 7, weight: .black))
                    .foregroundColor(index < starLevel ? Color(hex: "facc15") : Color.white.opacity(0.45))
            }
        }
    }
}

// MARK: - Block Detail View
struct BlockDetailView: View {
    let sel: SelectedBlock
    let namespace: Namespace.ID
    let onDismiss: () -> Void

    @EnvironmentObject private var vm: AppViewModel
    @State private var titleText: String
    @State private var selectedTemplateService: LinkedServiceTemplate?
    @State private var metricValue = 3
    @FocusState private var isTitleFocused: Bool

    private var completionCount: Int {
        vm.completionCount(for: sel.block.id)
    }

    private var starLevel: Int {
        vm.starLevel(for: sel.block.id)
    }

    init(sel: SelectedBlock, namespace: Namespace.ID, onDismiss: @escaping () -> Void) {
        self.sel = sel
        self.namespace = namespace
        self.onDismiss = onDismiss
        _titleText = State(initialValue: sel.block.title)
    }

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.zinc900)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.zinc800, lineWidth: 0.5)
                )
                .shadow(radius: 30)

            VStack(alignment: .leading, spacing: 0) {
                // Top accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(sel.block.cleared ? Color(hex: "facc15") : sel.color.primary)
                    .frame(height: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 32))

                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("アクション")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.zinc500)
                                .tracking(1)
                            TextField("アクションを入力", text: $titleText)
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.white)
                                .focused($isTitleFocused)
                                .submitLabel(.done)
                                .onSubmit(saveTitle)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.zinc800)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isTitleFocused ? sel.color.primary : Color.zinc700, lineWidth: 1)
                                )
                            linkedTemplatePicker
                        }
                        Spacer()
                        if sel.block.cleared {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "facc15"))
                                .padding(8)
                                .background(Color(hex: "facc15").opacity(0.15))
                                .clipShape(Circle())
                        }
                    }

                    // Star goal
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("達成スター")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.zinc400)
                            Spacer()
                            Text("\(completionCount) 回達成")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < starLevel ? "star.fill" : "star")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundColor(index < starLevel ? Color(hex: "facc15") : Color.zinc700)
                            }
                            Spacer()
                            Text("振り返りで「できた」を2回/5回/10回押すと星が増えます")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.zinc500)
                        }
                    }

                    Button(action: onDismiss) {
                        Text("閉じる")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.zinc400)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(24)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            if sel.block.title.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isTitleFocused = true
                }
            }
        }
        .onDisappear(perform: saveTitle)
    }

    private var linkedTemplatePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                serviceTemplateButton(.github)
                serviceTemplateButton(.googleCalendar)
            }

            if let selectedTemplateService {
                VStack(alignment: .leading, spacing: 8) {
                    Stepper(value: $metricValue, in: 1...20) {
                        Text("目標数: \(metricValue)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.zinc300)
                    }
                    .tint(sel.color.primary)

                    switch selectedTemplateService {
                    case .github:
                        HStack(spacing: 8) {
                            templateChip("\(metricValue) commit") {
                                titleText = "毎日\(metricValue)コミット"
                                saveTitle()
                            }
                            templateChip("\(metricValue) PR") {
                                titleText = "毎日\(metricValue) PR"
                                saveTitle()
                            }
                            templateChip("\(metricValue) Issue") {
                                titleText = "毎日\(metricValue) Issue"
                                saveTitle()
                            }
                        }
                        Text("自動達成はcommitのみ対応しています。PR/Issueはテンプレートとして入力できます。")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.zinc500)

                    case .googleCalendar:
                        HStack(spacing: 8) {
                            templateChip("\(metricValue) 予定", isEnabled: false) {}
                            templateChip("\(metricValue) 作業枠", isEnabled: false) {}
                        }
                        Text("Calendarは今は予定ログの取得のみです。予定数での自動達成は次の拡張候補です。")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.zinc500)
                    }
                }
                .padding(10)
                .background(Color.zinc800.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 4)
    }

    private func serviceTemplateButton(_ service: LinkedServiceTemplate) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTemplateService = selectedTemplateService == service ? nil : service
            }
        } label: {
            Label(service.title, systemImage: service.iconName)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(selectedTemplateService == service ? Color.zinc950 : service.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(selectedTemplateService == service ? service.tint : Color.zinc800)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func templateChip(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(isEnabled ? title : "\(title) 準備中")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isEnabled ? .white : Color.zinc500)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(isEnabled ? sel.color.primary : Color.zinc900)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }

    private func saveTitle() {
        vm.updateBlockTitle(
            categoryId: sel.categoryId,
            blockId: sel.block.id,
            title: titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

struct CategoryTitleEditorView: View {
    let category: SelectedCategory
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titleText: String
    @FocusState private var isFocused: Bool

    init(category: SelectedCategory, onSave: @escaping (String) -> Void) {
        self.category = category
        self.onSave = onSave
        _titleText = State(initialValue: category.title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("テーマを入力")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(Color.stone900)

            TextField("例: 技術力、健康、発信", text: $titleText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.stone900)
                .tint(category.color.primary)
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(saveAndDismiss)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.stone100)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isFocused ? category.color.primary : Color.stone200, lineWidth: 1)
                )

            Button(action: saveAndDismiss) {
                Text("保存")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(category.color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isFocused = true
            }
        }
    }

    private func saveAndDismiss() {
        onSave(titleText.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}

struct MainGoalEditorView: View {
    let title: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titleText: String
    @FocusState private var isFocused: Bool

    init(title: String, onSave: @escaping (String) -> Void) {
        self.title = title
        self.onSave = onSave
        _titleText = State(initialValue: title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("中心の目標を入力")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(Color.stone900)

            TextField("例: 技育CAMPで優勝する", text: $titleText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.stone900)
                .tint(Color.indigo600)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(saveAndDismiss)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.stone100)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isFocused ? Color.indigo600 : Color.stone200, lineWidth: 1)
                )

            Button(action: saveAndDismiss) {
                Text("保存")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.indigo600)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isFocused = true
            }
        }
    }

    private func saveAndDismiss() {
        onSave(titleText.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}

#Preview {
    BlockMandalartView()
        .environmentObject(AppViewModel())
}
