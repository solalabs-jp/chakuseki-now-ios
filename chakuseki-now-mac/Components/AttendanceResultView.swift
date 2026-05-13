import SwiftUI

struct AttendanceResultView: View {
    let answer: String
    let time: Date
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                sectionMarker(imageName: "time")

                Text("打刻時間:")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0.36, green: 0.25, blue: 0.24))

                Spacer()

                Text(timeFormatter.string(from: time))
                    .font(
                        Font.custom("Lexend", size: 17)
                            .weight(.semibold)
                    )
                    .foregroundColor(Color(red: 0.15, green: 0.09, blue: 0.08))
                    .frame(width: 78.27, height: 22, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            resultDivider
                .padding(.top, 16)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 8) {
                    sectionMarker(imageName: "comment")

                    Text("送信した回答:")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.36, green: 0.25, blue: 0.24))
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(answer)
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 144, maxHeight: 144, alignment: .topLeading)
                .background(Color(red: 0, green: 0.34, blue: 0.67).opacity(0.15))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.66, green: 0.78, blue: 1), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 290, maxHeight: 290, alignment: .topLeading)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.5)
                .stroke(Color(red: 0.66, green: 0.78, blue: 1), lineWidth: 1)
        )
    }

    private func sectionMarker(imageName: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundStyle(Color(red: 0, green: 0.34, blue: 0.67))
        }
        .padding(0)
        .frame(width: 32, height: 32, alignment: .center)
        .background(Color(red: 0, green: 0.34, blue: 0.67).opacity(0.15))
        .cornerRadius(9999)
    }

    private var resultDivider: some View {
        Rectangle()
            .fill(Color(red: 0.66, green: 0.78, blue: 1))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}
