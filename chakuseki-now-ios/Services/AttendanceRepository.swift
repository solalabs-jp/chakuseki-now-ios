import Foundation
import FirebaseFirestore

/// Firestore から「科目ごとの出席履歴」を取得するリポジトリ。
///
/// `attendanceRecords` は `scheduleId` を直接持たないため、
/// `attendanceRecords.sessionId` → `sessions.daily_sessionsId` → `dailySessions.scheduleId`
/// の join で対象科目のレコードだけに絞り込む。
struct AttendanceRepository {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    struct SubjectHistory {
        /// 対象科目の出席レコード（新しい順）。`sessionNumber` は科目内の第N回。
        let records: [AttendanceRecord]
        /// その科目の実施済み授業数（`dailySessions` のうち日付が現在以前のもの）。
        let totalSessions: Int
    }

    /// 指定ユーザーの、指定科目（`scheduleId`）に紐づく出席履歴を取得する。
    func fetchSubjectHistory(for userId: String, scheduleId: String) async throws -> SubjectHistory {
        async let recordsTask = db.collection("attendanceRecords")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        async let sessionsTask = db.collection("sessions")
            .whereField("studentId", isEqualTo: userId)
            .getDocuments()
        async let dailyTask = db.collection("dailySessions")
            .whereField("scheduleId", isEqualTo: scheduleId)
            .getDocuments()
        let (recordsSnapshot, sessionsSnapshot, dailySnapshot) = try await (recordsTask, sessionsTask, dailyTask)

        // sessionId -> daily_sessionsId
        var sessionToDaily: [String: String] = [:]
        for document in sessionsSnapshot.documents {
            if let dailyId = document.data()["daily_sessionsId"] as? String {
                sessionToDaily[document.documentID] = dailyId
            }
        }

        // この科目に属する dailySessionId 集合、および実施済み件数
        let now = Date()
        var scheduleDailyIds = Set<String>()
        var completedCount = 0
        for document in dailySnapshot.documents {
            scheduleDailyIds.insert(document.documentID)
            if let date = (document.data()["date"] as? Timestamp)?.dateValue(), date <= now {
                completedCount += 1
            }
        }

        // attendanceRecords をこの科目の分だけに絞る
        let dated: [(date: Date, status: AttendanceStatus)] = recordsSnapshot.documents.compactMap { document in
            let data = document.data()
            guard let statusValue = data["status"] as? String,
                  let status = AttendanceStatus(firestoreValue: statusValue),
                  let sessionId = data["sessionId"] as? String,
                  let dailyId = sessionToDaily[sessionId],
                  scheduleDailyIds.contains(dailyId) else {
                return nil
            }
            let timestamp = (data["confirmedAt"] as? Timestamp)
                ?? (data["firstDetectedAt"] as? Timestamp)
                ?? (data["lastDetectedAt"] as? Timestamp)
            return (timestamp?.dateValue() ?? .distantPast, status)
        }

        let numbered = dated
            .sorted { $0.date < $1.date }
            .enumerated()
            .map { index, item in
                AttendanceRecord(sessionNumber: index + 1, date: item.date, status: item.status)
            }

        return SubjectHistory(
            records: Array(numbered.reversed()),
            totalSessions: max(completedCount, numbered.count)
        )
    }
}
