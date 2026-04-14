import SwiftUI

class AppViewModel: ObservableObject {
    @Published var categories: [MandalartCategory] = MandalartCategory.sampleData
    @Published var isSyncing: Bool = false

    let mainGoal = "最強のエンジニアになる"
    let weeklyProgress: Double = 42

    func clearBlock(categoryId: Int, blockId: Int) {
        for ci in categories.indices {
            guard categories[ci].id == categoryId else { continue }
            for bi in categories[ci].blocks.indices {
                if categories[ci].blocks[bi].id == blockId {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        categories[ci].blocks[bi].cleared  = true
                        categories[ci].blocks[bi].progress = 100
                    }
                }
            }
        }
    }

    func triggerSync() {
        isSyncing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isSyncing = false
        }
    }
}
