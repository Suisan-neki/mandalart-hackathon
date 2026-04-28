import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var activeSheet: SettingsSheet?
    @State private var activeDemoPresentation: DemoPresentation?
    @State private var showResetAlert = false

    private enum SettingsSheet: String, Identifiable {
        case github
        case googleCalendar

        var id: String { rawValue }
    }

    private enum DemoPresentation: String, Identifiable {
        case launchTutorial
        case inputTutorial
        case errorScreen

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Connected services
                settingsSection(title: "連携サービス") {
                    serviceRow(
                        iconName: "chevron.left.forwardslash.chevron.right",
                        iconBg: Color.stone900,
                        label: "GitHub",
                        trailing: {
                            serviceStatusBadge(
                                text: vm.githubSettings.owner.isEmpty ? "未設定" : "@\(vm.githubSettings.owner)",
                                tint: vm.githubSettings.owner.isEmpty ? Color.red500 : Color.stone600,
                                background: vm.githubSettings.owner.isEmpty ? Color.red500.opacity(0.08) : Color.stone100
                            )
                        },
                        action: {
                            activeSheet = .github
                        }
                    )
                    Divider().padding(.horizontal, 16)
                    serviceRow(
                        iconName: "calendar",
                        iconBg: Color(hex: "2563eb"),
                        label: "Google Calendar",
                        trailing: {
                            serviceStatusBadge(
                                text: vm.hasGoogleCalendarToken ? vm.googleCalendarSettings.calendarId : "未設定",
                                tint: vm.hasGoogleCalendarToken ? Color(hex: "2563eb") : Color.red500,
                                background: vm.hasGoogleCalendarToken ? Color(hex: "dbeafe") : Color.red500.opacity(0.08)
                            )
                        },
                        action: {
                            activeSheet = .googleCalendar
                        }
                    )
                }

                // App settings
                settingsSection(title: "アプリ設定") {
                    HStack {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.stone100)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.stone500)
                            }
                            Text("同期通知")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.stone800)
                        }
                        Spacer()
                        // Custom toggle
                        ZStack(alignment: vm.notificationsEnabled ? .trailing : .leading) {
                            Capsule()
                                .fill(vm.notificationsEnabled ? Color.red500 : Color.stone300)
                                .frame(width: 44, height: 24)
                            Circle()
                                .fill(.white)
                                .frame(width: 18, height: 18)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                                .padding(3)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                vm.updateNotificationsEnabled(to: !vm.notificationsEnabled)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if vm.notificationsEnabled {
                        Text(notificationStatusText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.stone500)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    }

                    Divider().padding(.horizontal, 16)

                    Button(action: { showResetAlert = true }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.red500.opacity(0.08))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.red500)
                            }
                            Text("すべてのデータをリセット")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.red600)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }

                settingsSection(title: "デモ運用") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("発表で見せる導線だけをここから開けます。APIエラーやオフラインのシナリオには入りません。")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.stone500)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)

                        demoActionRow(
                            iconName: "figure.baseball",
                            title: "既存のチュートリアル",
                            subtitle: "大谷翔平のくだりから始まる導入を見る"
                        ) {
                            activeDemoPresentation = .launchTutorial
                        }

                        Divider().padding(.horizontal, 16)

                        demoActionRow(
                            iconName: "square.grid.3x3.fill",
                            title: "マンダラートの入力方法",
                            subtitle: "大目標、中目標、小目標を入れる流れを見る"
                        ) {
                            activeDemoPresentation = .inputTutorial
                        }

                        Divider().padding(.horizontal, 16)

                        demoActionRow(
                            iconName: "exclamationmark.triangle.fill",
                            title: "エラー画面",
                            subtitle: "同期に失敗したときの見え方だけ確認する",
                            tint: Color.red500,
                            background: Color.red500.opacity(0.08)
                        ) {
                            activeDemoPresentation = .errorScreen
                        }
                    }
                }

                Text("Mandalart Sync  Version 1.0.0")
                    .font(.system(size: 12))
                    .foregroundColor(Color.stone400)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color.stone50.ignoresSafeArea())
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .github:
                GitHubSettingsView()
                    .environmentObject(vm)
            case .googleCalendar:
                GoogleCalendarSettingsView()
                    .environmentObject(vm)
            }
        }
        .fullScreenCover(item: $activeDemoPresentation) { presentation in
            switch presentation {
            case .launchTutorial:
                LaunchTutorialView {
                    activeDemoPresentation = nil
                }
            case .inputTutorial:
                // 目標タブに移動してスポットライトを起動
                Color.clear
                    .onAppear {
                        activeDemoPresentation = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            vm.selectedTab = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                vm.showMandalartTutorial = true
                            }
                        }
                    }
            case .errorScreen:
                DemoErrorView {
                    activeDemoPresentation = nil
                }
            }
        }
        .alert("すべてのデータをリセットしますか？", isPresented: $showResetAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("リセット", role: .destructive) {
                vm.resetAllData()
            }
        } message: {
            Text("目標、記録、連携設定を初期状態に戻します。")
        }
    }

    // MARK: - Section Builder
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.stone500)
                .tracking(2)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22).stroke(Color.stone200, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
        }
    }

    // MARK: - Service Row
    @ViewBuilder
    private func serviceRow<Trailing: View>(
        iconName: String,
        iconBg: Color,
        iconFg: Color = .white,
        label: String,
        @ViewBuilder trailing: () -> Trailing,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 32, height: 32)
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                        .foregroundColor(iconFg)
                }
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.stone800)
                Spacer()
                trailing()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func serviceStatusBadge(text: String, tint: Color, background: Color) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(tint)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(background)
                .clipShape(Capsule())
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(Color.stone300)
        }
    }

    private func demoActionRow(
        iconName: String,
        title: String,
        subtitle: String,
        tint: Color = Color.indigo600,
        background: Color = Color.indigo100,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(background)
                        .frame(width: 34, height: 34)
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(tint)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.stone800)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.stone500)
                        .lineSpacing(3)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.stone300)
                    .padding(.top, 9)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var notificationStatusText: String {
        switch vm.notificationAuthorizationStatus {
        case .authorized, .provisional:
            return "GitHub のコミットと記録に差があるときに通知します。"
        case .denied:
            return "通知が無効です。必要なら iPhone の設定から再度許可してください。"
        case .notDetermined:
            return "初回起動時に通知許可を確認します。"
        case .ephemeral:
            return "一時的な通知権限で動作しています。"
        @unknown default:
            return "通知設定を確認中です。"
        }
    }

}

private struct DemoErrorView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.stone50.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.red500.opacity(0.1))
                        .frame(width: 108, height: 108)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(Color.red500)
                }

                VStack(spacing: 10) {
                    Text("同期に失敗しました")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color.stone900)
                    Text("GitHub または Google Calendar の認証情報を確認してください。入力した目標や記録は端末に保存されています。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.stone500)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.horizontal, 30)

                VStack(alignment: .leading, spacing: 10) {
                    Label("API Error 401", systemImage: "lock.slash.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.red600)
                    Text("アクセストークンが無効、または期限切れです。設定から再ログインすると同期を再開できます。")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.stone600)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.red500.opacity(0.16), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer()

                Button(action: onDismiss) {
                    Text("閉じる")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.stone900)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AppViewModel())
}
