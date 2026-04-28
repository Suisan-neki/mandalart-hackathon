import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 目標
            NavigationStack {
                BlockMandalartView()
            }
            .tabItem {
                Label("目標", systemImage: "square.grid.3x3.fill")
            }
            .tag(0)

            // Tab 2: アクション
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("アクション", systemImage: "checkmark.square.fill")
            }
            .tag(1)

            // Tab 3: 設定
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("設定", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .tint(Color.indigo600)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
