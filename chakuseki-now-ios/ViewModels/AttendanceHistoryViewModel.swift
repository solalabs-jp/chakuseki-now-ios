import Foundation
import Observation

@MainActor
@Observable
final class AttendanceHistoryViewModel {
    /// 未ログイン時などのフォールバック（Preview 用）。
    static let fallbackUserId = "student-001"

    private(set) var records: [AttendanceRecord] = []
    private(set) var totalSessions: Int = 0
    private(set) var state: LoadState = .idle

    private let repository: AttendanceRepository
    private let userId: String
    private let scheduleId: String

    init(
        scheduleId: String,
        repository: AttendanceRepository = AttendanceRepository(),
        userId: String? = nil
    ) {
        self.scheduleId = scheduleId
        self.repository = repository
        self.userId = userId ?? AuthService.shared.currentUserId ?? Self.fallbackUserId
    }

    func loadIfNeeded() async {
        guard state == .idle || state.isFailed else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let history = try await repository.fetchSubjectHistory(for: userId, scheduleId: scheduleId)
            records = history.records
            totalSessions = history.totalSessions
            state = .loaded
        } catch {
            records = []
            totalSessions = 0
            state = .failed(error.localizedDescription)
        }
    }
}
