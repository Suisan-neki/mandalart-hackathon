import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Connected services
                settingsSection(title: "連携サービス") {
                    serviceRow(
                        iconName: "chevron.left.forwardslash.chevron.right",
                        iconBg: Color.stone900,
                        label: "GitHub（連携済み）",
                        trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(Color.stone300)
                        }
                    )
                    Divider().padding(.horizontal, 16)
                    serviceRow(
                        iconName: "calendar",
                        iconBg: Color(hex: "2563eb"),
                        label: "Google Calendar（未連携）",
                        trailing: {
                            HStack(spacing: 8) {
                                Text("設定する")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color.red500)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red500.opacity(0.08))
                                    .clipShape(Capsule())
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.stone300)
                            }
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
                            Text("リマインド通知")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.stone800)
                        }
                        Spacer()
                        // Custom toggle
                        ZStack(alignment: notificationsEnabled ? .trailing : .leading) {
                            Capsule()
                                .fill(notificationsEnabled ? Color.red500 : Color.stone300)
                                .frame(width: 44, height: 24)
                            Circle()
                                .fill(.white)
                                .frame(width: 18, height: 18)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                                .padding(3)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                notificationsEnabled.toggle()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Divider().padding(.horizontal, 16)

                    Button(action: {}) {
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

                // Legal / Other
                settingsSection(title: "その他") {
                    serviceRow(
                        iconName: "shield.fill",
                        iconBg: Color.stone100,
                        iconFg: Color.stone500,
                        label: "プライバシーポリシー",
                        trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(Color.stone300)
                        }
                    )
                    Divider().padding(.horizontal, 16)
                    serviceRow(
                        iconName: "rectangle.portrait.and.arrow.right",
                        iconBg: Color.stone100,
                        iconFg: Color.stone500,
                        label: "ログアウト",
                        trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(Color.stone300)
                        }
                    )
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
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        Button(action: {}) {
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
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AppViewModel())
}
