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
        // Do not default to a fallback user here. Keep `userId` nil when not provided
        // so that sign-out (Auth -> nil) can reliably clear `records`.
        self.userId = userId ?? AuthService.shared.currentUserId
    }

    func load(for userId: String? = nil) async {
        // Prefer explicit argument, otherwise use the currently authenticated user.
        // Do NOT fall back to the previously stored `self.userId` when `userId` is nil:
        // that would retain a previous user's id after sign-out. If no user id
        // can be resolved, clear state.
        let targetUserId = userId ?? AuthService.shared.currentUserId
        guard let targetUserId else {
            // Ensure we drop any cached user id and clear records on sign-out
            self.userId = nil
            records = []
            state = .idle
            return
        }

        // Store the active user id for potential explicit reloads
        self.userId = targetUserId
        state = .loading
        do {
            records = try await repository.fetchAllRecords(for: targetUserId)
            state = .loaded
        } catch {
            records = []
            state = .failed(error.localizedDescription)
        }
    }
}
