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

    /// 指定ユーザーの、全出席履歴を取得する。
    func fetchAllRecords(for userId: String) async throws -> [AttendanceRecord] {
        let snapshot = try await db.collection("attendanceRecords")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        let records = snapshot.documents.compactMap(AttendanceRecord.init(fromFirestore:))

        return records.sorted { $0.date < $1.date }
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
            guard let record = AttendanceRecord(fromFirestore: document),
                  let sessionId = data["sessionId"] as? String,
                  let dailyId = sessionToDaily[sessionId],
                  scheduleDailyIds.contains(dailyId) else {
                return nil
            }
            return (record.date, record.status)
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

private extension AttendanceRecord {
    init?(fromFirestore document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let statusValue = data["status"] as? String,
            let status = AttendanceStatus(firestoreValue: statusValue)
        else {
            return nil
        }

        // Some legacy/manual records may only have a subset of timestamp fields or none at all.
        // Preserve them instead of dropping them: they still count as attendance history and should
        // not reduce `totalSessions` when `numbered.count` is used for the fallback branch.
        let timestamp = (data["confirmedAt"] as? Timestamp)?.dateValue()
            ?? (data["firstDetectedAt"] as? Timestamp)?.dateValue()
            ?? (data["lastDetectedAt"] as? Timestamp)?.dateValue()
            ?? .distantPast

        self.init(sessionNumber: 0, date: timestamp, status: status)
    }
}
