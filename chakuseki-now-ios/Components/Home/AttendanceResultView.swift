import SwiftUI

struct AttendanceResultView: View {
    let answer: String
    let time: Date
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                sectionMarker(imageName: "time")

                Text("打刻時間:")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.brownText)

                Spacer()

                Text(timeFormatter.string(from: time))
                    .font(
                        Font.custom("Lexend", size: 17)
                            .weight(.semibold)
                    )
                    .foregroundColor(AppColors.darkBrownText)
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
                        .foregroundColor(AppColors.brownText)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(answer)
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 144, maxHeight: 144, alignment: .topLeading)
                .background(AppColors.attendanceBlueBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.5)
                        .stroke(AppColors.attendanceBlueBorder, lineWidth: 1)
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 290, maxHeight: 290, alignment: .topLeading)
        .background(AppColors.white)
        .cornerRadius(24)
        .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.5)
                .stroke(AppColors.attendanceBlueBorder, lineWidth: 1)
        )
    }

    private func sectionMarker(imageName: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundStyle(AppColors.attendanceBlue)
        }
        .padding(0)
        .frame(width: 32, height: 32, alignment: .center)
        .background(AppColors.attendanceBlueBackground)
        .cornerRadius(9999)
    }

    private var resultDivider: some View {
        Rectangle()
            .fill(AppColors.attendanceBlueBorder)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}
