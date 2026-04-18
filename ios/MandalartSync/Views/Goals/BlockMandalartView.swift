import SwiftUI

struct BlockMandalartView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedBlock: SelectedBlock? = nil
    @Namespace private var ns

    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    // Legend
                    HStack(spacing: 20) {
                        legendItem(color: Color.zinc800, label: "未着手")
                        legendItem(color: .white,        label: "継続中")
                        legendItem(color: Color(hex: "facc15"), label: "クリア済", glow: true)
                    }
                    .padding(.top, 16)

                    ForEach(vm.categories) { category in
                        CategoryGridView(
                            category: category,
                            namespace: ns,
                            onTap: { block in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selectedBlock = SelectedBlock(block: block, categoryId: category.id, color: category.color)
                                }
                            }
                        )
                    }
                }
                .padding(.bottom, 120)
            }

            // Block detail overlay
            if let sel = selectedBlock {
                blockDetailOverlay(sel)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 6) {
                    Image(systemName: "square.3.layers.3d")
                        .foregroundColor(Color.indigo400)
                    Text("現在の目標")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                viewModeToggle
            }
        }
        .toolbarBackground(Color.zinc950, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - View Mode Toggle
    @ViewBuilder
    private var viewModeToggle: some View {
        HStack(spacing: 4) {
            Label("ブロック", systemImage: "square.3.layers.3d")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.zinc800)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            NavigationLink(destination: MandalartListView()) {
                Label("リスト", systemImage: "square.grid.2x2")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundColor(Color.zinc500)
            }
            .buttonStyle(.plain)
        }
        .background(Color.zinc900)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
            onClear: {
                vm.clearBlock(categoryId: sel.categoryId, blockId: sel.block.id)
                withAnimation(.spring()) { selectedBlock = nil }
            },
            onDismiss: {
                withAnimation(.spring()) { selectedBlock = nil }
            }
        )
        .padding(.horizontal, 24)
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

// MARK: - Category Grid View
struct CategoryGridView: View {
    let category: MandalartCategory
    let namespace: Namespace.ID
    let onTap: (MandalartBlock) -> Void

    // Maps 8 blocks to a 3x3 grid (center = category label)
    private var gridOrder: [MandalartBlock?] {
        let b = category.blocks
        return [b[0], b[1], b[2], b[3], nil, b[4], b[5], b[6], b[7]]
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(category.title)
                .font(.system(size: 17, weight: .black))
                .foregroundColor(category.color.primary)

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
                            Text(category.title)
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(category.color.primary)
                                .multilineTextAlignment(.center)
                                .padding(6)
                        }
                        .aspectRatio(1, contentMode: .fit)
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
                        Text(block.title)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(block.cleared ? Color(hex: "78350f") : .white)
                            .lineLimit(3)
                            .padding(6)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if block.cleared {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "92400e"))
                                .padding(5)
                        } else {
                            resonanceDots
                                .padding(5)
                        }
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

    private var resonanceDots: some View {
        let level = Int(ceil(block.resonance / 100 * 3))
        return HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i < level ? Color.white : Color.black.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
        }
    }
}

// MARK: - Block Detail View
struct BlockDetailView: View {
    let sel: SelectedBlock
    let namespace: Namespace.ID
    let onClear: () -> Void
    let onDismiss: () -> Void

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
                            Text("Target Goal")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.zinc500)
                                .tracking(1)
                            Text(sel.block.title)
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.white)
                                .lineLimit(2)
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

                    // Progress bar
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("進捗度 (Progress)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.zinc400)
                            Spacer()
                            Text("\(Int(sel.block.progress))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.zinc800).frame(height: 8)
                                Capsule()
                                    .fill(sel.block.cleared ? Color(hex: "facc15") : sel.color.primary)
                                    .frame(width: g.size.width * CGFloat(sel.block.progress / 100), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }

                    // Resonance bar
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("達成率 (Achievement)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.zinc400)
                            Spacer()
                            Text("\(Int(sel.block.resonance)) / 100")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("目標に向けた行動の積み重ねを示します")
                            .font(.system(size: 10))
                            .foregroundColor(Color.zinc500)

                        HStack(spacing: 3) {
                            ForEach(0..<10, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        i < Int(ceil(sel.block.resonance / 10))
                                        ? (sel.block.cleared ? Color(hex: "facc15") : sel.color.primary)
                                        : Color.zinc800
                                    )
                                    .frame(height: 8)
                            }
                        }
                    }

                    // Actions
                    if !sel.block.cleared {
                        VStack(spacing: 10) {
                            Button(action: onClear) {
                                Label("目標をクリアする", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.zinc800)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.zinc700, lineWidth: 0.5)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            Button(action: onDismiss) {
                                Text("閉じる")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color.zinc400)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            Button(action: onDismiss) {
                                Label("新しい目標を積み上げる", systemImage: "square.3.layers.3d")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundColor(Color(hex: "1c1917"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(hex: "facc15"))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(color: Color(hex: "facc15").opacity(0.4), radius: 12)
                            }
                            Button(action: onDismiss) {
                                Text("閉じる")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color.zinc400)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    BlockMandalartView()
        .environmentObject(AppViewModel())
}
