import SwiftUI

struct DayCellView: View {
    let date: Date
    let isSelected: Bool

    var body: some View {
        Text("\(CalendarStyle.calendar.component(.day, from: date))")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? CalendarStyle.selectionColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
