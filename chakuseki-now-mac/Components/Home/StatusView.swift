// ステータス表示
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
            } else {
                // 1ページ目 (検索中) と 3ページ目 (出席完了)
                HStack(alignment: .center, spacing: 0) { 
                    if status == .searching {
                        Image("reader")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else {
                        Image("RedIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(0)
                .frame(width: 40, height: 40, alignment: .center)
                .background(AppColors.warningRedBackground)
                .cornerRadius(9999)
            }

            // Space Between
            let displayTeacher = (status == .connecting ? teacherName : nil) ?? "先生"
            Text(status == .searching ? "\(displayTeacher)の信号を検索しています..." : "\(displayTeacher)の信号と接続中...")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppColors.labelPrimary)
                .frame(height: 40, alignment: .top)
            
            Spacer()
            
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
                // 3ページ目 (出席完了)
                VStack(alignment: .leading, spacing: 0) {
                    Text("アクティブ")
                        .font(
                            Font.custom("SF Pro", size: 12)
                                .weight(.medium)
                        )
                        .foregroundColor(AppColors.successGreenText)
                        .frame(width: 61.41, height: 16, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AppColors.successGreenBackground)
                .cornerRadius(9999)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .inset(by: 0.5)
                        .stroke(AppColors.successGreenBorder, lineWidth: 1)
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
                .stroke(AppColors.cardBorder, lineWidth: 1)
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
