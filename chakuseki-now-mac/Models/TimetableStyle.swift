import SwiftUI

enum TimetableStyle {
    // ボタンのスタイル
    static let rowBackground = AppColors.timetableRowBackground
    static let outlineColor = AppColors.timetableRowOutline
    static let timeColor = AppColors.timetableRowTime
    static let cornerRadius: CGFloat = 12
    static let spacing: CGFloat = 12
    
    // レイアウト
    static let horizontalPadding: CGFloat = 16
    static let topPadding: CGFloat = 16
    
    // フォント
    static let dateFont: Font = .headline
}
