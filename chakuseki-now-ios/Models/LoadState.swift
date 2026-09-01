import Foundation

/// 非同期読み込みの状態を表す共通 enum。
enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)

    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }
}
