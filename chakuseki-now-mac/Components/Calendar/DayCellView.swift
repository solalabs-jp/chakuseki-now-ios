import SwiftUI

struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    var hasEvent: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text("\(CalendarStyle.calendar.component(.day, from: date))")
                .font(.body)
                .foregroundColor(isSelected ? AppColors.white : AppColors.labelPrimary)
                .frame(width: 32, height: 32)
                .background(isSelected ? CalendarStyle.selectionColor : AppColors.clear)
                .clipShape(Circle())
            
            if hasEvent {
                Circle()
                    .fill(CalendarStyle.markerColor)
                    .frame(width: CalendarStyle.markerSize, height: CalendarStyle.markerSize)
            } else {
                Spacer()
                    .frame(height: CalendarStyle.markerSize)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
