import Foundation
import Observation

@MainActor
@Observable
final class TimetableViewModel {
    private(set) var state: LoadState = .idle

    private var timetable: Timetable = .empty
    private let repository: TimetableRepository
    private let userId: String

    init(
        repository: TimetableRepository = TimetableRepository(),
        userId: String? = nil
    ) {
        self.repository = repository
        self.userId = userId ?? AuthService.shared.currentUserId ?? AttendanceHistoryViewModel.fallbackUserId
    }

    func loadIfNeeded() async {
        guard state == .idle || state.isFailed else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            timetable = try await repository.loadTimetable(for: userId)
            state = .loaded
        } catch {
            timetable = .empty
            state = .failed(error.localizedDescription)
        }
    }

    func entries(on date: Date) -> [TimetableEntry] {
        timetable.entries(on: date)
    }
}
