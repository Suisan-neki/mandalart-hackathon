import SwiftUI

struct GitHubSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: AppViewModel

    @State private var owner = ""
    @State private var repository = ""
    @State private var token = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("リポジトリ") {
                    TextField("ユーザー名", text: $owner)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("リポジトリ名", text: $repository)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Personal Access Token") {
                    SecureField("必要な場合のみ入力", text: $token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("公開リポジトリならトークンなしでも取得できます。非公開リポジトリやレート制限回避が必要な場合のみ PAT を入れてください。")
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
                        vm.updateGitHubSettings(owner: owner, repository: repository, token: token)
                        dismiss()
                    }
                }
            }
            .onAppear {
                owner = vm.githubSettings.owner
                repository = vm.githubSettings.repository
                token = vm.storedGitHubToken() ?? ""
            }
        }
    }
}

#Preview {
    GitHubSettingsView()
        .environmentObject(AppViewModel())
}
