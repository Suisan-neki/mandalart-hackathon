import SwiftUI

struct GitHubSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: AppViewModel

    @State private var owner = ""
    @State private var token = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("GitHub アカウント") {
                    TextField("ユーザー名（例: octocat）", text: $owner)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("特定のリポジトリではなく、このユーザーのGitHub EventsからPushEventを取得し、コミット件数を自動で数えます。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section("Personal Access Token") {
                    SecureField("必要な場合のみ入力", text: $token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("公開アクティビティならトークンなしでも取得できます。レート制限回避や認証済みユーザーとして取得したい場合のみ PAT を入れてください。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("GitHub 連携")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        vm.updateGitHubSettings(owner: owner, token: token)
                        dismiss()
                    }
                }
            }
            .onAppear {
                owner = vm.githubSettings.owner
                token = vm.storedGitHubToken() ?? ""
            }
        }
    }
}

#Preview {
    GitHubSettingsView()
        .environmentObject(AppViewModel())
}
