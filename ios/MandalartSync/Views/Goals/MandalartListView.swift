import SwiftUI

struct MandalartListView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var expandedId: Int? = nil

    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach($vm.categories) { $category in
                        CategoryCard(
                            category: $category,
                            isExpanded: expandedId == category.id,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    expandedId = expandedId == category.id ? nil : category.id
                                }
                            },
                            onSave: {
                                vm.appendSystemEntry(
                                    action: "マンダラートを更新しました",
                                    detail: "「\(category.title)」の内容を保存しました。",
                                    targetGoal: vm.mainGoal
                                )
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    expandedId = nil
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(vm.mainGoal)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.zinc950, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    @Binding var category: MandalartCategory
    let isExpanded: Bool
    let onTap: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: category.color))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(category.color.primary)
                    Text(category.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.zinc500)
                }
                .padding(20)
            }

            // Action chips
            if !isExpanded {
                // Preview: first 4 chips
                FlowLayout(spacing: 6) {
                    ForEach(category.blocks.prefix(4)) { block in
                        Text(block.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.zinc300)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.zinc900.opacity(0.6))
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.05))
                            )
                            .clipShape(Capsule())
                    }
                    if category.blocks.count > 4 {
                        Text("+\(category.blocks.count - 4)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.zinc400)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Expanded: all blocks as editable rows
            if isExpanded {
                VStack(spacing: 10) {
                    TextField("サブテーマ名", text: $category.title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .textInputAutocapitalization(.never)

                    Text("「\(category.title)」を構成する8つのアクション。タップして編集できます。")
                        .font(.system(size: 12))
                        .foregroundColor(Color.zinc400)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)

                    ForEach(Array(category.blocks.indices), id: \.self) { index in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(category.color.primary)
                                .clipShape(Circle())
                            TextField("アクションを入力", text: $category.blocks[index].title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.never)
                            Spacer()
                            if category.blocks[index].cleared {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "facc15"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.zinc900)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 12)
                    }

                    // Save button
                    Button(action: onSave) {
                        Label("変更を保存", systemImage: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(category.color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(category.color.light)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(category.color.border, lineWidth: 0.5)
                )
        )
    }

    private func iconName(for color: CategoryColor) -> String {
        switch color {
        case .blue:   return "cpu"
        case .orange: return "flame.fill"
        case .green:  return "figure.walk"
        case .purple: return "bolt.fill"
        }
    }
}

// MARK: - Simple Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        MandalartListView()
    }
    .environmentObject(AppViewModel())
}
