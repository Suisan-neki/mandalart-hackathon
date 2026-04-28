import Foundation

struct GitHubCommit: Decodable {
    let sha: String
    let commit: CommitPayload

    struct CommitPayload: Decodable {
        let message: String
        let author: AuthorPayload?
    }

    struct AuthorPayload: Decodable {
        let date: Date?
    }
}

protocol GitHubCommitFetching {
    func fetchCommits(owner: String, repository: String, token: String?) async throws -> [GitHubCommit]
}

enum GitHubServiceError: LocalizedError {
    case invalidRepository
    case unauthorized
    case forbidden
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidRepository:
            return "GitHub のユーザー名 / リポジトリ名が未設定です。設定から入力してください。"
        case .unauthorized:
            return "GitHub のトークンが無効です（401）。設定からトークンを再設定してください。"
        case .forbidden:
            return "GitHub へのアクセスが拒否されました（403）。トークンの権限を確認してください。"
        case .requestFailed:
            return "GitHub からコミット履歴を取得できませんでした。"
        }
    }

    var requiresTokenReset: Bool {
        self == .unauthorized || self == .forbidden
    }
}

struct GitHubService: GitHubCommitFetching {
    func fetchCommits(owner: String, repository: String, token: String?) async throws -> [GitHubCommit] {
        guard !owner.isEmpty, !repository.isEmpty else {
            throw GitHubServiceError.invalidRepository
        }

        let escapedOwner = owner.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? owner
        let escapedRepository = repository.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? repository
        guard let url = URL(string: "https://api.github.com/repos/\(escapedOwner)/\(escapedRepository)/commits?per_page=10") else {
            throw GitHubServiceError.requestFailed
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("MandalartSync", forHTTPHeaderField: "User-Agent")

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubServiceError.requestFailed
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try decoder.decode([GitHubCommit].self, from: data)
        case 401:
            throw GitHubServiceError.unauthorized
        case 403:
            throw GitHubServiceError.forbidden
        default:
            throw GitHubServiceError.requestFailed
        }
    }
}
