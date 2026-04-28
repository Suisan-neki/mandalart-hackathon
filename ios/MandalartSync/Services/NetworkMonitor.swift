import Foundation
import Network

/// ネットワーク接続状態をリアルタイムで監視するサービス。
/// `AppViewModel` が `@Published isOffline` を通じて View に伝達する。
final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "mandalart-sync.network-monitor")

    /// 接続が失われたときに呼ばれるコールバック（MainActor 上で実行される）
    var onStatusChange: ((Bool) -> Void)?

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isOffline = path.status != .satisfied
            DispatchQueue.main.async {
                self?.onStatusChange?(isOffline)
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }

    deinit {
        stop()
    }
}
