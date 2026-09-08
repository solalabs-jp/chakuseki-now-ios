import SwiftUI

struct ProfileCardView: View {
    let records: [AttendanceRecord]
    let levelTitle: String
    let levelProgress: CGFloat
    let remainingExpText: String

    init(records: [AttendanceRecord] = []) {
        self.records = records
        let derivedInfo = GrowthSystem.levelInfo(for: records)
        self.levelTitle = derivedInfo.levelTitle
        self.levelProgress = CGFloat(derivedInfo.progressRatio)
        self.remainingExpText = derivedInfo.remainingExpText
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
