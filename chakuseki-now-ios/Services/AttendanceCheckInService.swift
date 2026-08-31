import Foundation
import Observation
import FirebaseFirestore

/// 先生のビーコン検知 → 出席レコード作成 → 一言コメント送信で出席確定、までを Firestore に書き込む。
///
/// 仕様書 4.1（`docs/spec.md`）:
/// - ビーコン検知時: 当日の `dailySessions`（教員一致・自クラス）を特定し、`periods` から算出した
///   授業時間ウィンドウ（開始 `earlyGraceMinutes` 前 〜 終了）内でのみ受付。`sessions` と
///   `attendanceRecords` を作成（`firstDetectedAt` / `detectionMethod = "ble"` / `status = "absent"` 未確定）。
/// - 一言コメント送信時: `status` を確定（開始 `lateThresholdMinutes` 超で `late`、それ以内で `present`）、
///   `confirmedAt` を記録し、`checkinAnswers` を作成。
/// - 滞在継続判定・30分離席の自動判定・GPS は本サービスの対象外（Cloud Functions 想定）。
@MainActor
@Observable
final class AttendanceCheckInService {
    enum Phase: Equatable {
        case idle
        case resolving          // ビーコン検知後、対象授業を解決中
        case detected           // 初回レコード作成済み、コメント待ち
        case confirmed          // コメント送信済み、status 確定
        case failed(String)
    }

    /// 授業開始の何分前から受付を許可するか。
    private static let earlyGraceMinutes = 15
    /// 授業開始から何分を超えたコメント送信を「遅刻」とみなすか。
    private static let lateThresholdMinutes = 15
    /// 滞在監視のハートビート間隔（秒）。仕様 7.2 は 5 分だが前面監視用に短めにしている。
    private static let heartbeatSeconds: UInt64 = 60
    /// 直近この秒数以内にビーコンを検知していれば「圏内」とみなす。
    private static let presenceStaleSeconds: TimeInterval = 90
    /// この秒数以上連続でビーコンが途切れたら「中抜け（mid_absence）」と自動判定。仕様 4.1: 30 分。
    private static let absenceThresholdSeconds: TimeInterval = 30 * 60

    private(set) var phase: Phase = .idle
    private(set) var subjectName: String?
    private(set) var teacherName: String?
    /// コメント送信で確定した status（"present" / "late"）。監視中は "mid_absence" / "early_leave" に更新され得る。
    private(set) var confirmedStatus: String?
    /// 滞在監視中に表示する状況テキスト。
    private(set) var monitorInfo: String?

    private var monitorTask: Task<Void, Never>?

    private let db = Firestore.firestore()
    private static let jst = TimeZone(identifier: "Asia/Tokyo") ?? .current

    private struct Context {
        let dailySessionId: String
        let scheduleId: String
        let sessionDocId: String
        let recordDocId: String
        let beaconUUID: String
        let classStart: Date
        let classEnd: Date
    }
    private var context: Context?

    var errorMessage: String? {
        if case .failed(let message) = phase { return message }
        return nil
    }

    func reset() {
        monitorTask?.cancel()
        monitorTask = nil
        phase = .idle
        context = nil
        subjectName = nil
        teacherName = nil
        confirmedStatus = nil
        monitorInfo = nil
    }

    // MARK: - スキャン対象の教員ビーコン一覧

    func fetchTeacherBeaconUUIDs() async -> [UUID] {
        do {
            let snapshot = try await db.collection("users")
                .whereField("role", isEqualTo: "teacher")
                .getDocuments()
            return snapshot.documents.compactMap { document in
                guard let raw = document.data()["beaconId"] as? String, !raw.isEmpty else { return nil }
                return UUID(uuidString: raw)
            }
        } catch {
            return []
        }
    }

    // MARK: - ビーコン検知

    func handleBeaconDetected(uuid: UUID) async {
        guard let profile = AuthService.shared.currentProfile else {
            phase = .failed("ログイン情報が取得できませんでした")
            return
        }
        phase = .resolving
        let beaconUUID = uuid.uuidString.uppercased()

        do {
            // 1. beaconId から教員を特定
            let teacherSnapshot = try await db.collection("users")
                .whereField("beaconId", isEqualTo: beaconUUID)
                .limit(to: 1)
                .getDocuments()
            guard let teacherDoc = teacherSnapshot.documents.first,
                  (teacherDoc.data()["role"] as? String) == "teacher" else {
                phase = .failed("このビーコンに対応する教員が見つかりません")
                return
            }
            let teacherId = teacherDoc.documentID
            teacherName = teacherDoc.data()["name"] as? String

            // 2. 本日 (JST) の dailySession（教員一致・自分のクラス）を全て集め、時限ごとの時間ウィンドウを付与
            async let daySnapshotTask = db.collection("dailySessions")
                .whereField("teacherId", isEqualTo: teacherId)
                .getDocuments()
            async let periodSnapshotTask = db.collection("periods").getDocuments()
            let (daySnapshot, periodSnapshot) = try await (daySnapshotTask, periodSnapshotTask)

            var periodWindow: [String: (start: Int, end: Int)] = [:]
            for document in periodSnapshot.documents {
                let data = document.data()
                if let start = Self.intValue(data["startAt"]), let end = Self.intValue(data["endAt"]) {
                    periodWindow[document.documentID] = (start, end)
                }
            }

            struct Candidate {
                let dailySessionId: String
                let scheduleId: String
                let subjectName: String?
                let classStart: Date
                let classEnd: Date
            }

            var scheduleCache: [String: [String: Any]] = [:]
            var candidates: [Candidate] = []
            for document in daySnapshot.documents {
                let data = document.data()
                guard let date = (data["date"] as? Timestamp)?.dateValue(),
                      Self.isSameJSTDay(date, Date()),
                      let scheduleId = data["scheduleId"] as? String, !scheduleId.isEmpty else {
                    continue
                }
                let schedule: [String: Any]
                if let cached = scheduleCache[scheduleId] {
                    schedule = cached
                } else {
                    schedule = (try await db.collection("schedules").document(scheduleId).getDocument()).data() ?? [:]
                    scheduleCache[scheduleId] = schedule
                }
                guard (schedule["classId"] as? String) == profile.classId,
                      let periodId = schedule["periodId"] as? String,
                      let window = periodWindow[periodId],
                      let classStart = Self.time(hhmm: window.start),
                      let classEnd = Self.time(hhmm: window.end) else {
                    continue
                }
                candidates.append(Candidate(
                    dailySessionId: document.documentID,
                    scheduleId: scheduleId,
                    subjectName: schedule["subjectName"] as? String,
                    classStart: classStart,
                    classEnd: classEnd
                ))
            }

            guard !candidates.isEmpty else {
                phase = .failed("本日の対象授業が見つかりません")
                return
            }

            // 3. 現在時刻が受付ウィンドウ（開始 earlyGraceMinutes 前 〜 終了）に入る授業を選ぶ
            let now = Date()
            let grace = Double(Self.earlyGraceMinutes * 60)
            let inWindow = candidates
                .filter { now >= $0.classStart.addingTimeInterval(-grace) && now <= $0.classEnd }
                .sorted { $0.classStart < $1.classStart }
            let selected = inWindow.first { now >= $0.classStart && now <= $0.classEnd } ?? inWindow.first

            guard let selected else {
                let upcoming = candidates
                    .filter { now < $0.classStart.addingTimeInterval(-grace) }
                    .min { $0.classStart < $1.classStart }
                if let upcoming {
                    phase = .failed("次の授業（\(Self.hhmmString(from: upcoming.classStart)) 開始）まで受付できません")
                } else {
                    phase = .failed("本日の授業は終了しています")
                }
                return
            }

            subjectName = selected.subjectName
            let classStart = selected.classStart
            let classEnd = selected.classEnd
            let match = (dailySessionId: selected.dailySessionId, scheduleId: selected.scheduleId)

            let sessionDocId = "\(match.dailySessionId)__\(profile.userId)"
            let recordDocId = "rec_\(sessionDocId)"

            // 3. sessions を upsert（ER: daily_sessionsId / studentId / beaconId / gps / createAt）
            try await db.collection("sessions").document(sessionDocId).setData([
                "studentId": profile.userId,
                "daily_sessionsId": match.dailySessionId,
                "beaconId": beaconUUID,
                "gpsLat": 0,
                "gpsLng": 0,
                "createAt": Timestamp(date: now),
            ], merge: true)

            // 4. attendanceRecords を作成 / 更新（初回検知レコード）
            let recordRef = db.collection("attendanceRecords").document(recordDocId)
            let existing = try await recordRef.getDocument()
            if existing.exists {
                try await recordRef.updateData(["lastDetectedAt": Timestamp(date: now)])
            } else {
                try await recordRef.setData([
                    "sessionId": sessionDocId,
                    "userId": profile.userId,
                    "status": "absent",              // コメント送信で "present" / "late" に確定
                    "detectionMethod": "ble",
                    "firstDetectedAt": Timestamp(date: now),
                    "lastDetectedAt": Timestamp(date: now),
                    "confirmedAt": NSNull(),
                    "absenceMinutes": 0,
                    "isExcused": false,
                    "excusedReason": "",
                    "excusedFrom": NSNull(),
                    "excusedTo": NSNull(),
                ])
            }

            context = Context(
                dailySessionId: match.dailySessionId,
                scheduleId: match.scheduleId,
                sessionDocId: sessionDocId,
                recordDocId: recordDocId,
                beaconUUID: beaconUUID,
                classStart: classStart,
                classEnd: classEnd
            )
            phase = .detected
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    // MARK: - 一言コメント送信（出席確定）

    func submitComment(_ text: String) async {
        guard let profile = AuthService.shared.currentProfile, let context else {
            phase = .failed("出席セッションが確立されていません")
            return
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isSkipped = trimmed.isEmpty
        let now = Date()

        // 開始から lateThresholdMinutes を超えていれば「遅刻」フラグ（教員が後で承認・修正）
        let lateBound = context.classStart.addingTimeInterval(Double(Self.lateThresholdMinutes * 60))
        let status = now > lateBound ? "late" : "present"

        do {
            try await db.collection("attendanceRecords").document(context.recordDocId).updateData([
                "status": status,
                "confirmedAt": Timestamp(date: now),
                "lastDetectedAt": Timestamp(date: now),
            ])

            let questionSnapshot = try await db.collection("checkinQuestions")
                .whereField("sessionId", isEqualTo: context.dailySessionId)
                .limit(to: 1)
                .getDocuments()
            let questionId = questionSnapshot.documents.first?.documentID ?? ""

            let answerDocId = "ans_\(context.dailySessionId)__\(profile.userId)"
            try await db.collection("checkinAnswers").document(answerDocId).setData([
                "questionId": questionId,
                "attendance_reId": context.recordDocId,
                "userId": profile.userId,
                "answerText": isSkipped ? "" : trimmed,
                "isSkipped": isSkipped,
                "answeredAt": Timestamp(date: now),
            ], merge: true)

            confirmedStatus = status
            phase = .confirmed
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    // MARK: - 復元（アプリ再起動時）

    /// 現在時刻に該当する自クラスの授業について、既にコメント送信済み（`confirmedAt` あり）なら
    /// その回答内容・確定時刻を返し、内部状態（`context` / `phase = .confirmed`）を復元する。
    /// アプリを閉じて開き直しても入力欄ではなく送信済み画面を出すために使う。
    func restoreActiveCheckIn() async -> (answer: String, time: Date)? {
        guard let profile = AuthService.shared.currentProfile,
              let classId = profile.classId, !classId.isEmpty else {
            return nil
        }

        do {
            let today = Date()
            let weekday = Self.jstWeekday(today)

            let scheduleSnapshot = try await db.collection("schedules")
                .whereField("classId", isEqualTo: classId)
                .whereField("dayOfWeek", isEqualTo: weekday)
                .getDocuments()
            guard !scheduleSnapshot.documents.isEmpty else { return nil }

            let periodSnapshot = try await db.collection("periods").getDocuments()
            var periodWindow: [String: (start: Int, end: Int)] = [:]
            for document in periodSnapshot.documents {
                let data = document.data()
                if let start = Self.intValue(data["startAt"]), let end = Self.intValue(data["endAt"]) {
                    periodWindow[document.documentID] = (start, end)
                }
            }

            struct Slot {
                let dailySessionId: String
                let scheduleId: String
                let subjectName: String?
                let teacherId: String?
                let classStart: Date
                let classEnd: Date
            }

            var slots: [Slot] = []
            for scheduleDoc in scheduleSnapshot.documents {
                let scheduleData = scheduleDoc.data()
                guard let periodId = scheduleData["periodId"] as? String,
                      let window = periodWindow[periodId],
                      let classStart = Self.time(hhmm: window.start),
                      let classEnd = Self.time(hhmm: window.end) else {
                    continue
                }
                let dailySnapshot = try await db.collection("dailySessions")
                    .whereField("scheduleId", isEqualTo: scheduleDoc.documentID)
                    .getDocuments()
                guard let dailyDoc = dailySnapshot.documents.first(where: {
                    ($0.data()["date"] as? Timestamp).map { Self.isSameJSTDay($0.dateValue(), today) } ?? false
                }) else { continue }

                slots.append(Slot(
                    dailySessionId: dailyDoc.documentID,
                    scheduleId: scheduleDoc.documentID,
                    subjectName: scheduleData["subjectName"] as? String,
                    teacherId: dailyDoc.data()["teacherId"] as? String,
                    classStart: classStart,
                    classEnd: classEnd
                ))
            }

            let now = Date()
            guard let current = slots.first(where: { now >= $0.classStart && now <= $0.classEnd })
                ?? slots.filter({ now <= $0.classEnd }).min(by: { $0.classStart < $1.classStart }) else {
                return nil
            }

            let recordDocId = "rec_\(current.dailySessionId)__\(profile.userId)"
            let recordDoc = try await db.collection("attendanceRecords").document(recordDocId).getDocument()
            guard recordDoc.exists,
                  let confirmedAt = (recordDoc.data()?["confirmedAt"] as? Timestamp)?.dateValue() else {
                return nil
            }

            let answerDoc = try await db.collection("checkinAnswers")
                .document("ans_\(current.dailySessionId)__\(profile.userId)")
                .getDocument()
            let isSkipped = (answerDoc.data()?["isSkipped"] as? Bool) ?? false
            let answerText = (answerDoc.data()?["answerText"] as? String) ?? ""
            let displayAnswer = (isSkipped || answerText.isEmpty) ? "（スキップ）" : answerText

            if let teacherId = current.teacherId, !teacherId.isEmpty {
                let teacherDoc = try await db.collection("users").document(teacherId).getDocument()
                teacherName = teacherDoc.data()?["name"] as? String
            }
            subjectName = current.subjectName
            confirmedStatus = recordDoc.data()?["status"] as? String
            context = Context(
                dailySessionId: current.dailySessionId,
                scheduleId: current.scheduleId,
                sessionDocId: "\(current.dailySessionId)__\(profile.userId)",
                recordDocId: recordDocId,
                beaconUUID: "",
                classStart: current.classStart,
                classEnd: current.classEnd
            )
            phase = .confirmed
            return (displayAnswer, confirmedAt)
        } catch {
            return nil
        }
    }

    // MARK: - 滞在の継続監視（仕様 4.1）

    /// コメント送信後、授業終了まで前面でビーコンの圏内/圏外を監視し、
    /// `lastDetectedAt` / `absenceMinutes` を更新、30分以上途切れたら `mid_absence` に自動フラグ。
    /// `beaconLastSeen` は BeaconManager の `lastSeenAt` を返すクロージャ。
    func startMonitoring(beaconLastSeen: @escaping @MainActor @Sendable () -> Date?) {
        guard let context, phase == .confirmed else { return }
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            await self?.runMonitor(context: context, beaconLastSeen: beaconLastSeen)
        }
    }

    func stopMonitoring() {
        monitorTask?.cancel()
        monitorTask = nil
    }

    private func runMonitor(
        context: Context,
        beaconLastSeen: @MainActor @Sendable () -> Date?
    ) async {
        let recordRef = db.collection("attendanceRecords").document(context.recordDocId)
        var awaySince: Date?
        var cumulativeAwaySeconds: TimeInterval = 0
        var flaggedMidAbsence = false

        while !Task.isCancelled {
            let now = Date()
            if now >= context.classEnd { break }

            let lastSeen = beaconLastSeen()
            let inRange = lastSeen.map { now.timeIntervalSince($0) <= Self.presenceStaleSeconds } ?? false

            if inRange {
                if let since = awaySince {
                    cumulativeAwaySeconds += now.timeIntervalSince(since)
                    awaySince = nil
                }
                try? await recordRef.updateData(["lastDetectedAt": Timestamp(date: now)])
                monitorInfo = flaggedMidAbsence
                    ? "在室を再検知しました（中抜け記録あり・先生の承認待ち）"
                    : "出席を継続監視中です"
            } else {
                let since = awaySince ?? now
                awaySince = since
                let continuousAway = now.timeIntervalSince(since)
                let totalAway = cumulativeAwaySeconds + continuousAway
                var update: [String: Any] = ["absenceMinutes": Int(totalAway / 60)]

                if continuousAway >= Self.absenceThresholdSeconds && !flaggedMidAbsence {
                    update["status"] = "mid_absence"
                    flaggedMidAbsence = true
                    confirmedStatus = "mid_absence"
                }
                try? await recordRef.updateData(update)
                monitorInfo = flaggedMidAbsence
                    ? "中抜けとして記録しました（先生の承認・修正待ち）"
                    : "ビーコン圏外を検知中（\(Int(continuousAway / 60))分）"
            }

            try? await Task.sleep(nanoseconds: Self.heartbeatSeconds * 1_000_000_000)
        }

        guard !Task.isCancelled else { return }

        // 授業終了時の締め
        let end = Date()
        if let since = awaySince {
            let totalAway = cumulativeAwaySeconds + end.timeIntervalSince(since)
            let stillAway = end.timeIntervalSince(since) >= Self.absenceThresholdSeconds
            var update: [String: Any] = ["absenceMinutes": Int(totalAway / 60)]
            if stillAway {
                update["status"] = "early_leave"   // 授業終了時点で圏外 → 早退（教員が承認・修正）
                confirmedStatus = "early_leave"
            }
            try? await recordRef.updateData(update)
        }
        monitorInfo = "授業終了：出席の監視を終了しました"
    }

    // MARK: - Helpers

    private static func isSameJSTDay(_ lhs: Date, _ rhs: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jst
        return calendar.isDate(lhs, inSameDayAs: rhs)
    }

    /// JST の曜日（0=日 〜 6=土）。`schedules.dayOfWeek` と揃える。
    private static func jstWeekday(_ date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jst
        return calendar.component(.weekday, from: date) - 1
    }

    /// hhmm 整数（例 915）を、本日 (JST) のその時刻を指す Date にする。
    private static func time(hhmm: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jst
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hhmm / 100
        components.minute = hhmm % 100
        components.second = 0
        return calendar.date(from: components)
    }

    private static func hhmmString(_ hhmm: Int) -> String {
        String(format: "%02d:%02d", hhmm / 100, hhmm % 100)
    }

    private static func hhmmString(from date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jst
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }

    private static func intValue(_ value: Any?) -> Int? {
        switch value {
        case let int as Int: return int
        case let int64 as Int64: return Int(int64)
        case let number as NSNumber: return number.intValue
        case let string as String: return Int(string)
        default: return nil
        }
    }
}
