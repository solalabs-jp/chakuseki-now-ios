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
                .background(Color(red: 0, green: 0.34, blue: 0.67).opacity(0.15))
                .cornerRadius(9999)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.66, green: 0.78, blue: 1), lineWidth: 1)
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
                .background(Color(red: 0.69, green: 0.05, blue: 0.06).opacity(0.1))
                .cornerRadius(9999)
            }

            // Space Between
            Text(status == .searching ? "先生の信号を検索しています..." : "先生の信号と接続中...")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.primary)
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
                        .foregroundColor(Color(red: 0, green: 0.34, blue: 0.67))
                        .frame(width: 61.41, height: 16, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0, green: 0.34, blue: 0.67).opacity(0.15))
                .cornerRadius(9999)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.66, green: 0.78, blue: 1), lineWidth: 1)
                )
            } else {
                // 3ページ目 (出席完了)
                VStack(alignment: .leading, spacing: 0) {
                    Text("アクティブ")
                        .font(
                            Font.custom("SF Pro", size: 12)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.09, green: 0.4, blue: 0.2))
                        .frame(width: 61.41, height: 16, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.86, green: 0.99, blue: 0.91))
                .cornerRadius(9999)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.73, green: 0.97, blue: 0.82), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.5)
                .stroke(Color(red: 0.89, green: 0.75, blue: 0.72), lineWidth: 1)
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
    .background(Color(white: 0.95))
}
