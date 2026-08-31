import Foundation
import FirebaseFirestore

/// Firestore から時間割（`schedules` + `periods`）と、その日の出席ステータスを取得する。
///
/// スキーマ（ER 図準拠）:
/// - `schedules/{scheduleId}` : `classId`, `subjectName`, `dayOfWeek`(0=日〜6=土), `periodId`(FK)
/// - `periods/{periodId}` : `startAt` / `endAt`(Int, hhmm 例 915), `period`(Int)
/// - 出席ステータスは `attendanceRecords`(userId) × `sessions`(studentId) を `sessionId` で突き合わせ、
///   `sessions.daily_sessionsId` → `dailySessions.scheduleId` と `sessions.createAt` の日付で (日, 科目) に対応付ける。
struct TimetableRepository {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func loadTimetable(for userId: String) async throws -> Timetable {
        let classId = try await fetchClassId(for: userId)
        let periods = try await fetchPeriods()

        async let schedulesTask = fetchSchedules(classId: classId, periods: periods)
        async let statusTask = fetchStatusByDay(for: userId)
        let (slots, statusByDay) = try await (schedulesTask, statusTask)

        return Timetable(slots: slots, statusByDay: statusByDay)
    }

    // MARK: - Private

    private struct PeriodInfo {
        let number: Int
        let timeString: String
        let endHHMM: Int?
    }

    private func fetchClassId(for userId: String) async throws -> String? {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()?["classId"] as? String
    }

    private func fetchPeriods() async throws -> [String: PeriodInfo] {
        let snapshot = try await db.collection("periods").getDocuments()

        var result: [String: PeriodInfo] = [:]
        for document in snapshot.documents {
            let data = document.data()
            let number = intValue(data["period"]) ?? 0
            let end = intValue(data["endAt"])
            var timeString = ""
            if let start = intValue(data["startAt"]), let end {
                timeString = "\(Self.hhmm(start)) - \(Self.hhmm(end))"
            }
            result[document.documentID] = PeriodInfo(number: number, timeString: timeString, endHHMM: end)
        }
        return result
    }

    /// hhmm 整数（例 915, 1045）を "09:15" 形式に整形する。
    private static func hhmm(_ value: Int) -> String {
        String(format: "%02d:%02d", value / 100, value % 100)
    }

    private func fetchSchedules(classId: String?, periods: [String: PeriodInfo]) async throws -> [TimetableSlot] {
        var query: Query = db.collection("schedules")
        if let classId {
            query = query.whereField("classId", isEqualTo: classId)
        }
        let snapshot = try await query.getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let subjectName = data["subjectName"] as? String else { return nil }
            let periodId = data["periodId"] as? String ?? ""
            let period = periods[periodId]
            return TimetableSlot(
                id: document.documentID,
                subjectName: subjectName,
                dayOfWeek: intValue(data["dayOfWeek"]) ?? 0,
                periodNumber: period?.number ?? 99,
                timeString: period?.timeString ?? "",
                endHHMM: period?.endHHMM
            )
        }
    }

    private func fetchStatusByDay(for userId: String) async throws -> [String: [String: AttendanceStatus]] {
        async let recordsTask = db.collection("attendanceRecords")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        async let sessionsTask = db.collection("sessions")
            .whereField("studentId", isEqualTo: userId)
            .getDocuments()
        let (recordsSnapshot, sessionsSnapshot) = try await (recordsTask, sessionsTask)

        let dayFormatter = DateFormatter()
        dayFormatter.timeZone = Timetable.jst
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyy-MM-dd"

        // sessions は scheduleId を持たない（ER）。daily_sessionsId 経由で dailySessions.scheduleId を解決する。
        var pending: [(sessionId: String, dailySessionId: String, day: String)] = []
        var dailySessionIds = Set<String>()
        for document in sessionsSnapshot.documents {
            let data = document.data()
            guard let dailySessionId = data["daily_sessionsId"] as? String,
                  let createdAt = data["createAt"] as? Timestamp else { continue }
            pending.append((document.documentID, dailySessionId, dayFormatter.string(from: createdAt.dateValue())))
            dailySessionIds.insert(dailySessionId)
        }

        var scheduleIdByDailySession: [String: String] = [:]
        try await withThrowingTaskGroup(of: (String, String?).self) { group in
            for id in dailySessionIds {
                group.addTask {
                    let doc = try await db.collection("dailySessions").document(id).getDocument()
                    return (id, doc.data()?["scheduleId"] as? String)
                }
            }
            for try await (id, scheduleId) in group {
                if let scheduleId { scheduleIdByDailySession[id] = scheduleId }
            }
        }

        var sessionInfo: [String: (scheduleId: String, day: String)] = [:]
        for item in pending {
            guard let scheduleId = scheduleIdByDailySession[item.dailySessionId] else { continue }
            sessionInfo[item.sessionId] = (scheduleId, item.day)
        }

        var statusByDay: [String: [String: AttendanceStatus]] = [:]
        for document in recordsSnapshot.documents {
            let data = document.data()
            guard let sessionId = data["sessionId"] as? String,
                  let info = sessionInfo[sessionId],
                  let statusValue = data["status"] as? String,
                  let status = AttendanceStatus(firestoreValue: statusValue) else { continue }
            statusByDay[info.day, default: [:]][info.scheduleId] = status
        }
        return statusByDay
    }

    private func intValue(_ value: Any?) -> Int? {
        switch value {
        case let int as Int: return int
        case let int64 as Int64: return Int(int64)
        case let number as NSNumber: return number.intValue
        case let string as String: return Int(string)
        default: return nil
        }
    }
}
