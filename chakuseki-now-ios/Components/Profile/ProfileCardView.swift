import SwiftUI

struct ProfileCardView: View {
    let levelInfo: GrowthLevelInfo

    init(levelInfo: GrowthLevelInfo = GrowthSystem.levelInfo(for: [])) {
        self.levelInfo = levelInfo
    }

    var body: some View {
        ProfileLevelSectionView(
            levelTitle: levelInfo.levelTitle,
            levelProgress: CGFloat(levelInfo.progressRatio),
            remainingExpText: levelInfo.remainingExpText
        )
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
