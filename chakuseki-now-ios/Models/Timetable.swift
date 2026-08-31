import Foundation

/// 時間割の1コマ（`schedules` の1ドキュメントに相当）。
struct TimetableSlot: Identifiable {
    let id: String          // scheduleId
    let subjectName: String
    let dayOfWeek: Int       // 0=日 〜 6=土（ER 準拠）
    let periodNumber: Int
    let timeString: String   // 例: "09:15 - 10:45"
    let endHHMM: Int?        // 終了時刻（hhmm 例 1045）
}

/// 画面に表示する時間割の1行。
/// `status` が nil のとき: 授業が終了済みなら「終了」、まだなら「予定」。
struct TimetableEntry: Identifiable {
    let scheduleId: String
    let subjectName: String
    let timeString: String
    let status: AttendanceStatus?
    /// 選択日のこのコマの終了時刻が現在時刻を過ぎているか。
    let hasEnded: Bool

    var id: String { scheduleId }
}

/// ユーザーの時間割と、日付ごとの出席ステータスを保持する値オブジェクト。
struct Timetable {
    let slots: [TimetableSlot]
    /// "yyyy-MM-dd"(JST) -> scheduleId -> status
    let statusByDay: [String: [String: AttendanceStatus]]

    static let empty = Timetable(slots: [], statusByDay: [:])

    static let jst = TimeZone(identifier: "Asia/Tokyo") ?? .current

    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = jst
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// 指定日の授業を時限順で返す。
    func entries(on date: Date) -> [TimetableEntry] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.jst
        let weekday = calendar.component(.weekday, from: date) - 1 // 1(日)〜7(土) -> 0〜6
        let key = Self.dayKey(for: date)
        let statuses = statusByDay[key] ?? [:]
        let now = Date()

        return slots
            .filter { $0.dayOfWeek == weekday }
            .sorted { $0.periodNumber < $1.periodNumber }
            .map { slot in
                let ended = slot.endHHMM
                    .flatMap { Self.dateTime(on: date, hhmm: $0, calendar: calendar) }
                    .map { $0 < now } ?? false
                return TimetableEntry(
                    scheduleId: slot.id,
                    subjectName: slot.subjectName,
                    timeString: slot.timeString,
                    status: statuses[slot.id],
                    hasEnded: ended
                )
            }
    }

    /// 指定日の hhmm(例 1045) 時刻を指す Date（JST）。
    private static func dateTime(on date: Date, hhmm: Int, calendar: Calendar) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hhmm / 100
        components.minute = hhmm % 100
        components.second = 0
        return calendar.date(from: components)
    }
}
