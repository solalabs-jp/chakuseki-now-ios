import SwiftUI

enum CalendarStyle {
    static let locale = Locale(identifier: "ja_JP")
    static let weekDays = ["日", "月", "火", "水", "木", "金", "土"]
    static let selectionColor = AppColors.calendarSelection
    static let controlColor = AppColors.calendarControl
    static let markerSize: CGFloat = 4
    static let markerColor = AppColors.calendarMarker
    
    static var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = locale
        return cal
    }
    
    static func monthYearString(for date: Date) -> String {
        date.formatted(.dateTime.year().month(.wide).locale(locale))
    }
}
