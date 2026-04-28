import Foundation

struct GitHubCommit: Equatable {
    let sha: String
    let message: String
    let repositoryName: String
    let date: Date
}

protocol GitHubCommitFetching {
    func fetchCommits(username: String, token: String?) async throws -> [GitHubCommit]
}

enum GitHubServiceError: LocalizedError {
    case invalidUsername
    case unauthorized
    case forbidden
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidUsername:
            return "GitHub のユーザー名が未設定です。設定から入力してください。"
        case .unauthorized:
            return "GitHub のトークンが無効です（401）。設定からトークンを再設定してください。"
        case .forbidden:
            return "GitHub へのアクセスが拒否されました（403）。トークンの権限を確認してください。"
        case .requestFailed:
            return "GitHub からアカウントの活動履歴を取得できませんでした。"
        }
    }

    var requiresTokenReset: Bool {
        self == .unauthorized || self == .forbidden
    }
}

struct GitHubService: GitHubCommitFetching {
    func fetchCommits(username: String, token: String?) async throws -> [GitHubCommit] {
        guard !username.isEmpty else {
            throw GitHubServiceError.invalidUsername
        }

        let escapedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
        guard let url = URL(string: "https://api.github.com/users/\(escapedUsername)/events?per_page=100") else {
            throw GitHubServiceError.requestFailed
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("MandalartSync", forHTTPHeaderField: "User-Agent")

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubServiceError.requestFailed
        }

        switch httpResponse.statusCode {
        case 200..<300:
            let events = try decoder.decode([GitHubEvent].self, from: data)
            return events.flatMap { event -> [GitHubCommit] in
                guard event.type == "PushEvent" else { return [] }
                return (event.payload.commits ?? []).map { commit in
                    GitHubCommit(
                        sha: commit.sha,
                        message: commit.message,
                        repositoryName: event.repo.name,
                        date: event.createdAt
                    )
                }
            }
        case 401:
            throw GitHubServiceError.unauthorized
        case 403:
            throw GitHubServiceError.forbidden
        default:
            throw GitHubServiceError.requestFailed
        }
    }
}

private struct GitHubEvent: Decodable {
    let type: String
    let repo: Repo
    let payload: Payload
    let createdAt: Date

    struct Repo: Decodable {
        let name: String
    }

    struct Payload: Decodable {
        let commits: [Commit]?
    }

    struct Commit: Decodable {
        let sha: String
        let message: String
    }
}
