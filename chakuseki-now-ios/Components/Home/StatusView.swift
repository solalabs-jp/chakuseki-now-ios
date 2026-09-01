import SwiftUI

struct StatusView: View {
    // 状態を定義する（検索中か、接続中か）
    enum Status {
        case searching
        case connecting
    }
    
    // 現在の状態
    var status: Status
    // 3ページ目（出席完了）かどうか
    var isAttended: Bool = false
    
    // 先生の名前 (UUIDから識別したもの)
    var teacherName: String? = nil

    // 確定した出欠ステータス（出席/遅刻/早退/中抜け等）。未確定なら nil。
    var attendanceStatus: AttendanceStatus? = nil

    private var displayTeacher: String {
        (status == .connecting ? teacherName : nil) ?? "先生"
    }

    private var statusText: String {
        let joiner = "\u{2060}"  // WORD JOINER: 内部で改行不可
        let brk = "\u{200B}"     // ZERO WIDTH SPACE: ここで改行してよい
        func noBreak(_ s: String) -> String { s.map(String.init).joined(separator: joiner) }
        if status == .searching {
            return "\(displayTeacher)の信号を" + brk + noBreak("検索しています…")
        } else {
            return "\(displayTeacher)の信号と" + brk + noBreak("接続中…")
        }
    }

    // 状態に応じた枠線の色
    private var borderColor: Color {
        if isAttended, let attendanceStatus {
            return attendanceStatus.color             // 出席完了: 出欠ステータス色に揃える
        } else if status == .connecting && !isAttended {
            return AppColors.attendanceBlueBorder     // 接続中: 青
        } else if isAttended {
            return AppColors.successGreenBorder        // 出席完了（ステータス不明）: 緑
        } else {
            return AppColors.cardBorder                // 検索中
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            
            // 左側の丸いアイコン枠
            if status == .connecting && !isAttended {
                // 2ページ目 (接続中)
                HStack(alignment: .center, spacing: 0) { 
                    Image("BlueIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(0)
                .frame(width: 40, height: 40, alignment: .center)
                .background(AppColors.attendanceBlueBackground)
                .cornerRadius(9999)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .inset(by: 0.5)
                        .stroke(AppColors.attendanceBlueBorder, lineWidth: 1)
                )
            } else if status == .searching {
                // 1ページ目 (検索中)
                Image("reader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(AppColors.warningRedBackground)
                    .cornerRadius(9999)
            } else {
                // 3ページ目 (出席完了) — Bluetooth アイコンを出欠ステータス色に揃える
                Image("BlueIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(attendanceStatus?.color ?? AppColors.successGreenText)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(attendanceStatus?.pillBackgroundColor ?? AppColors.successGreenBackground)
                    .cornerRadius(9999)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9999)
                            .inset(by: 0.5)
                            .stroke(attendanceStatus?.pillBorderColor ?? AppColors.successGreenBorder, lineWidth: 1)
                    )
            }

            // Space Between
            Text(statusText)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppColors.labelPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 40, alignment: .leading)
                .layoutPriority(1)

            Spacer(minLength: 8)
            
            // 右側の要素 (ProgressView or Badge)
            if status == .searching {
                // 1ページ目
                ProgressView()
                    .controlSize(.small)
            } else if status == .connecting && !isAttended {
                // 2ページ目 (接続中・未回答)
                VStack(alignment: .leading, spacing: 0) {
                    Text("アクティブ")
                        .font(
                            Font.custom("SF Pro", size: 12)
                                .weight(.medium)
                        )
                        .foregroundColor(AppColors.attendanceBlue)
                        .frame(width: 61.41, height: 16, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AppColors.attendanceBlueBackground)
                .cornerRadius(9999)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .inset(by: 0.5)
                        .stroke(AppColors.attendanceBlueBorder, lineWidth: 1)
                )
            } else {
                // 3ページ目 (出席完了) — 出欠ステータスに応じた色・ラベル
                HStack(spacing: 4) {
                    if let attendanceStatus {
                        Image(systemName: attendanceStatus.iconName)
                            .font(.system(size: 10, weight: .bold))
                    }
                    Text(attendanceStatus?.rawValue ?? "アクティブ")
                        .font(Font.custom("SF Pro", size: 12).weight(.semibold))
                }
                .foregroundColor(attendanceStatus?.color ?? AppColors.successGreenText)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(attendanceStatus?.pillBackgroundColor ?? AppColors.successGreenBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .inset(by: 0.5)
                        .stroke(attendanceStatus?.pillBorderColor ?? AppColors.successGreenBorder, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(AppColors.white)
        .cornerRadius(24)
        .shadow(color: AppColors.shadow, radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.5)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

// プレビュー
#Preview {
    VStack(spacing: 20) {
        StatusView(status: .searching)
        StatusView(status: .connecting)
    }
    .padding()
    .background(AppColors.placeholderBackground)
}
