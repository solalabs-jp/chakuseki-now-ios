import SwiftUI

struct AttendanceStatusBadgeView: View {
    let status: AttendanceStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: 10))

            Text(status.rawValue)
                .font(.system(size: 12, weight: .bold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundColor(status.color)
        .background(status.pillBackgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(status.pillBorderColor, lineWidth: 1)
        )
    }
}

#Preview {
    AttendanceStatusBadgeView(status: .attendance)
        .padding()
}
