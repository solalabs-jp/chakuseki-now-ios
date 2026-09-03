import Foundation
import Observation

@MainActor
@Observable
final class GrowthViewModel {
    static let fallbackUserId = "student-001"

    private let repository: AttendanceRepository
    private var userId: String?

    var records: [AttendanceRecord] = []
    var state: LoadState = .idle

    init(
        repository: AttendanceRepository = AttendanceRepository(),
        userId: String? = nil
    ) {
        self.repository = repository
        self.userId = userId ?? AuthService.shared.currentUserId ?? Self.fallbackUserId
    }

    func load(for userId: String? = nil) async {
        let targetUserId = userId ?? self.userId ?? AuthService.shared.currentUserId
        guard let targetUserId else {
            records = []
            state = .idle
            return
        }

        self.userId = targetUserId
        state = .loading
        do {
            records = try await repository.fetchAllRecords(for: targetUserId)
            records.sort { $0.date < $1.date }
            state = .loaded
        } catch {
            records = []
            state = .failed(error.localizedDescription)
        }
    }
}
