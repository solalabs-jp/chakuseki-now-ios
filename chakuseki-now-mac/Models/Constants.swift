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

    static let timetableRowBackground = Color.secondary.opacity(0.05)
    static let placeholderBackground = Color(white: 0.95)
    static let placeholderText = Color.secondary.opacity(0.35)

    static let profileBadge = Color.red
    static let profileOverlay = Color.black.opacity(0.7)

    static let statusAttendance = Color(red: 0x13 / 255.0, green: 0x5D / 255.0, blue: 0xB2 / 255.0)
    static let statusAbsence = Color.red
    static let statusOfficialAbsence = Color.blue
    static let statusBereavement = Color.gray
    static let statusEarlyDeparture = Color.orange
    static let statusTardiness = Color.yellow
}

struct Constants {
    // Figma等で指定されている色。一旦は標準のprimaryカラーを当てています。
    static let LabelsVibrantPrimary = AppColors.labelPrimary
}
