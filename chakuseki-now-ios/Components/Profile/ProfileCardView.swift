import SwiftUI

struct ProfileCardView: View {
    let records: [AttendanceRecord]
    let levelTitle: String
    let levelProgress: CGFloat
    let remainingExpText: String

    init(
        records: [AttendanceRecord] = [],
        levelTitle: String = "レベル〇〇",
        levelProgress: CGFloat = 0.42,
        remainingExpText: String = "進化まであと〇〇○EXP!"
    ) {
        let derivedInfo = GrowthSystem.levelInfo(for: records)
        self.records = records

        if records.isEmpty {
            self.levelTitle = "レベル 1"
            self.levelProgress = 0
            self.remainingExpText = "進化まであと 180EXP!"
        } else {
            self.levelTitle = derivedInfo.levelTitle
            self.levelProgress = CGFloat(derivedInfo.progressRatio)
            self.remainingExpText = derivedInfo.remainingExpText
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ProfileLevelSectionView(
                levelTitle: levelTitle,
                levelProgress: levelProgress,
                remainingExpText: remainingExpText
            )
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.white)
        .cornerRadius(12)
        .overlay(cardBorder)
        .padding(.vertical, 8)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.5)
            .stroke(AppColors.cardBorder.opacity(0.3), lineWidth: 1)
    }
}

#Preview {
    ProfileCardView()
        .padding()
}
