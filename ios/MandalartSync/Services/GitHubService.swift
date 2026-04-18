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
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidRepository:
            return "GitHub の owner / repository が未設定です。"
        case .requestFailed:
            return "GitHub からコミット履歴を取得できませんでした。"
        }
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
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw GitHubServiceError.requestFailed
        }

        return try decoder.decode([GitHubCommit].self, from: data)
    }
}
