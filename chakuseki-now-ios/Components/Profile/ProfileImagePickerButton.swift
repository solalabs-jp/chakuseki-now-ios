import SwiftUI

struct ProfileImagePickerButton: View {
    let selectedImage: UIImage?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomTrailing) {
                profileImageContent
                    .frame(width: 192, height: 192)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(profileImageBorder)

                if selectedImage != nil {
                    Text("変更")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.profileOverlay)
                        .clipShape(Capsule())
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 33)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var profileImageContent: some View {
        if let selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(AppColors.profileIcon)

                Text("画像を選択")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.labelPrimary)

                Text("クリックしてアップロード")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.labelSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.softProfileBackground)
        }
    }

    private var profileImageBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(
                selectedImage == nil ? AppColors.cardBorder : AppColors.clear,
                style: StrokeStyle(lineWidth: 1.5, dash: [7, 5])
            )
    }
}

#Preview {
    ProfileImagePickerButton(selectedImage: nil, onTap: {})
        .padding()
}
