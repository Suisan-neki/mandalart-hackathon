import SwiftUI

struct GoogleCalendarSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: AppViewModel

    @State private var calendarId = ""
    @State private var accessToken = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("カレンダー") {
                    TextField("例: primary", text: $calendarId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("通常は primary のままで使えます。共有カレンダーを使う場合は対象の ID を入力してください。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section("アクセストークン") {
                    SecureField("Google OAuth アクセストークン", text: $accessToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("Google Calendar API の実取得には有効なアクセストークンが必要です。取得したトークンは Keychain に保存します。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Google Calendar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        vm.updateGoogleCalendarSettings(calendarId: calendarId, accessToken: accessToken)
                        dismiss()
                    }
                }
            }
            .onAppear {
                calendarId = vm.googleCalendarSettings.calendarId
                accessToken = vm.storedGoogleCalendarAccessToken() ?? ""
            }
        }
    }
}

#Preview {
    GoogleCalendarSettingsView()
        .environmentObject(AppViewModel())
}
