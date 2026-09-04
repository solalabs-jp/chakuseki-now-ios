import SwiftUI

struct ProfileLevelSectionView: View {
    let levelTitle: String
    let levelProgress: CGFloat
    let remainingExpText: String

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 9) {
                Circle()
                    .fill(AppColors.profileBadge)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppColors.white)
                    )

                Text(levelTitle)
                    .font(.system(size: 17))
                    .foregroundColor(AppColors.black)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 0) {
                Text("EXP")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.black)

                VStack(spacing: 12) {
                    GeometryReader { geometry in
                        VStack(alignment: .leading, spacing: 0) {
                            RoundedRectangle(cornerRadius: 9999)
                                .fill(Color(red: 0.07, green: 0.36, blue: 0.7))
                                .frame(width: geometry.size.width * levelProgress, height: 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                        .background(Color(red: 0.98, green: 0.86, blue: 0.85))
                        .cornerRadius(9999)
                    }
                    .frame(height: 12)

                    Text(remainingExpText)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 17)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.top, 24)
        .padding(.bottom, 24)
    }
}

#Preview {
    ProfileLevelSectionView(
        levelTitle: "レベル〇〇",
        levelProgress: 0.42,
        remainingExpText: "進化まであと〇〇○EXP!"
    )
    .frame(height: 358)
    .background(AppColors.white)
}
