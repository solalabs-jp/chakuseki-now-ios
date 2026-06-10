import SwiftUI

enum AppColors {
    static let labelPrimary = Color.primary
    static let labelSecondary = Color.secondary
    static let white = Color.white
    static let clear = Color.clear
    static let black = Color.black
    static let shadow = Color.black.opacity(0.02)
    static let strongShadow = Color.black.opacity(0.15)

    static let brandRed = Color(red: 211/255, green: 45/255, blue: 38/255)
    static let brandRedDisabled = Color.gray
    static let brandRedDeep = Color(red: 0.83, green: 0.18, blue: 0.15)
    static let brownText = Color(red: 0.36, green: 0.25, blue: 0.24)
    static let darkBrownText = Color(red: 0.15, green: 0.09, blue: 0.08)
    static let profileIcon = Color(red: 0.72, green: 0.48, blue: 0.44)
    static let softProfileBackground = Color(red: 0.99, green: 0.97, blue: 0.96)
    static let cardBorder = Color(red: 0.89, green: 0.75, blue: 0.72)
    static let messageInputBackground = Color(red: 1, green: 0.97, blue: 0.97)
    static let loginCardBackground = Color(red: 1, green: 0.97, blue: 0.97)
    static let loginCardBorder = Color(red: 1, green: 0.89, blue: 0.87)
    static let loginCardShadow = Color.black.opacity(0.03)
    static let loginTitle = Color(red: 0.69, green: 0.05, blue: 0.06)
    static let forgotPasswordText = Color(red: 0, green: 0.46, blue: 0.67)

    static let attendanceBlue = Color(red: 0, green: 0.34, blue: 0.67)
    static let attendanceBlueBackground = attendanceBlue.opacity(0.15)
    static let attendanceBlueBorder = Color(red: 0.66, green: 0.78, blue: 1)
    static let warningRedBackground = Color(red: 0.69, green: 0.05, blue: 0.06).opacity(0.1)
    static let successGreenText = Color(red: 0.09, green: 0.4, blue: 0.2)
    static let successGreenBackground = Color(red: 0.86, green: 0.99, blue: 0.91)
    static let successGreenBorder = Color(red: 0.73, green: 0.97, blue: 0.82)

    static let calendarSelection = Color.blue
    static let calendarControl = Color.red
    static let calendarMarker = Color.gray.opacity(0.5)
    static let calendarHeaderBackground = Color.secondary.opacity(0.1)
    static let calendarBackground = Color.secondary.opacity(0.05)
    static let calendarDebugBorder = Color.red

    static let timetableRowBackground = AppColors.white
    static let timetableRowOutline = Color(red: 0xE4 / 255.0, green: 0xBE / 255.0, blue: 0xB8 / 255.0).opacity(0.20)
    static let timetableRowTime = Color(red: 0x90 / 255.0, green: 0x6F / 255.0, blue: 0x6B / 255.0)
    static let placeholderBackground = Color(white: 0.95)
    static let placeholderText = Color.secondary.opacity(0.35)

    static let profileBadge = Color.red
    static let profileOverlay = Color.black.opacity(0.7)

    static let statusAttendance = Color(red: 0x13 / 255.0, green: 0x5D / 255.0, blue: 0xB2 / 255.0)
    static let statusAbsence = Color(red: 0xBA / 255.0, green: 0x1A / 255.0, blue: 0x1A / 255.0) // BA1A1A (badge text/icon)
    static let statusOfficialAbsence = Color(red: 6 / 255.0, green: 182 / 255.0, blue: 212 / 255.0)
    static let officialAbsenceOpacity = 0.30
    static let officialAbsenceBackground = Color(red: 207 / 255.0, green: 250 / 255.0, blue: 254 / 255.0).opacity(officialAbsenceOpacity)
    static let officialAbsenceBorder = Color(red: 165 / 255.0, green: 243 / 255.0, blue: 252 / 255.0)
    static let statusBereavement = Color.gray
    static let statusEarlyDeparture = Color(red: 0x84 / 255.0, green: 0xCC / 255.0, blue: 0x16 / 255.0)
    static let statusTardiness = Color(red: 0xF5 / 255.0, green: 0x9E / 255.0, blue: 0x0B / 255.0)

    // MARK: - Detail Page List Colors
    // Row backgrounds
    static let rowAttendanceBackground = Color.clear
    static let absenceBackgroundOpacity = 0.10
    static let rowAbsenceBackground = Color(red: 0xFF / 255.0, green: 0xDA / 255.0, blue: 0xD6 / 255.0).opacity(absenceBackgroundOpacity) // FFDAD6 (background)
    static let rowOfficialAbsenceBackground = officialAbsenceBackground
    static let rowBereavementBackground = Color.clear
    static let rowEarlyDepartureBackground = Color(red: 0xEC / 255.0, green: 0xFC / 255.0, blue: 0xCB / 255.0).opacity(0.30)
    static let rowTardinessBackground = Color.clear
    
    // Pill backgrounds
    static let pillAttendanceBackground = statusAttendance.opacity(0.12)
    static let pillAbsenceBackground = Color(red: 0xFF / 255.0, green: 0xDA / 255.0, blue: 0xD6 / 255.0).opacity(absenceBackgroundOpacity)
    static let pillOfficialAbsenceBackground = officialAbsenceBackground
    static let pillBereavementBackground = statusBereavement.opacity(0.12)
    static let pillEarlyDepartureBackground = statusEarlyDeparture.opacity(0.12)
    static let pillTardinessBackground = statusTardiness.opacity(0.12)
    
    // Pill borders
    static let pillAttendanceBorder = statusAttendance.opacity(0.25)
    static let pillAbsenceBorder = Color(red: 0xE4 / 255.0, green: 0xBE / 255.0, blue: 0xB8 / 255.0) // E4BEB8 (outline)
    static let pillOfficialAbsenceBorder = officialAbsenceBorder
    static let pillBereavementBorder = statusBereavement.opacity(0.25)
    static let pillEarlyDepartureBorder = statusEarlyDeparture.opacity(0.25)
    static let pillTardinessBorder = statusTardiness.opacity(0.25)
}

struct Constants {
    // Figma等で指定されている色。一旦は標準のprimaryカラーを当てています。
    static let LabelsVibrantPrimary = AppColors.labelPrimary
}
