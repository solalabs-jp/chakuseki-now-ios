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

    var levelInfo: GrowthLevelInfo {
        GrowthSystem.levelInfo(for: records)
    }

    init(
        repository: AttendanceRepository = AttendanceRepository(),
        userId: String? = nil
    ) {
        self.repository = repository
        // Do not default to a fallback user here. Keep `userId` nil when not provided
        // so that sign-out (Auth -> nil) can reliably clear `records`.
        self.userId = userId ?? AuthService.shared.currentUserId
    }

    func loadIfNeeded(for userId: String? = nil) async {
        let targetUserId = userId ?? AuthService.shared.currentUserId

        guard let targetUserId else {
            await load(for: nil)
            return
        }

        let isSameUser = self.userId == targetUserId
        let isAlreadyLoading = state == .loading
        let isAlreadyLoaded = state == .loaded
        guard !(isSameUser && (isAlreadyLoading || isAlreadyLoaded)) else {
            return
        }

        await load(for: targetUserId)
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
            let fetched = try await repository.fetchAllRecords(for: targetUserId)
            // Discard results if sign-out or an account switch happened while fetching.
            guard self.userId == targetUserId else { return }
            records = fetched
            state = .loaded
        } catch {
            guard self.userId == targetUserId else { return }
            records = []
            state = .failed(error.localizedDescription)
        }
    }
}
