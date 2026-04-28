import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if vm.isFirstLaunch {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: vm.isFirstLaunch)
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
