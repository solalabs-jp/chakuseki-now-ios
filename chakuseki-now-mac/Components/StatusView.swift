// ステータス表示
import SwiftUI

struct StatusView: View {
    // 状態を定義する（検索中か、接続中か）
    enum Status {
        case searching
        case connecting
    }
    
    // 現在の状態（外側から指定できるようにします）
    var status: Status
    // 表示する対象の名前（例：「デバイス」など）
    var targetName: String = "デバイス"

    var body: some View {
        VStack(spacing: 20) {
            if status == .searching {
                Text("\(targetName)を検索しています...")
                    .foregroundColor(.gray)
            } else {
                Text("\(targetName)と接続中...")
                    .foregroundColor(.blue)
            }
        }
    }
}

// プレビュー（今は「検索中」の状態にしています）
#Preview {
    StatusView(status: .searching)
}
