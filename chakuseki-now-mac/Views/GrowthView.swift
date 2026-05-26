import PhotosUI
import SwiftUI

struct GrowthView: View {
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedProfileImage: UIImage? = GrowthView.loadSavedProfileImage()

    private static let imageStorageKey = "growthView.profileImageData"
    private let levelProgress: CGFloat = 0.42

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("マイページ")
                    .font(.system(size: 24, weight: .bold))
                    .kerning(0.4)
                    .foregroundColor(AppColors.labelPrimary)
                    .frame(width: 241, height: 41, alignment: .topLeading)

                Spacer()
            }

            ZStack(alignment: .top) {
                profileImageButton
                levelSection
            }
            .frame(maxWidth: .infinity, minHeight: 358, maxHeight: 358)
            .background(AppColors.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(AppColors.cardBorder.opacity(0.3), lineWidth: 1)
            )
            .padding(.top, 61)
            .padding(.horizontal, -16)
            .photosPicker(
                isPresented: $isPhotoPickerPresented,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { _, newValue in
                guard let newValue else {
                    return
                }

                Task {
                    await loadSelectedPhoto(from: newValue)
                }
            }

            Spacer()
        }
        .padding(.top, 1.5)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var profileImageButton: some View {
        Button(action: { isPhotoPickerPresented = true }) {
            ZStack(alignment: .bottomTrailing) {
                profileImageContent
                    .frame(width: 192, height: 192)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(profileImageBorder)

                if selectedProfileImage != nil {
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
        if let selectedProfileImage {
            Image(uiImage: selectedProfileImage)
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
                selectedProfileImage == nil ? AppColors.cardBorder : AppColors.clear,
                style: StrokeStyle(lineWidth: 1.5, dash: [7, 5])
            )
    }

    private var levelSection: some View {
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

                Text("レベル〇〇")
                    .font(.system(size: 17))
                    .foregroundColor(AppColors.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 111)

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
                        .padding(0)
                        .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                        .background(Color(red: 0.98, green: 0.86, blue: 0.85))
                        .cornerRadius(9999)
                    }
                    .frame(height: 12)

                    Text("進化まであと〇〇○EXP!")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 17)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 241)
    }

    @MainActor
    private func loadSelectedPhoto(from item: PhotosPickerItem) async {
        guard
            let imageData = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: imageData)
        else {
            return
        }

        selectedProfileImage = image
        UserDefaults.standard.set(imageData, forKey: Self.imageStorageKey)
    }

    private static func loadSavedProfileImage() -> UIImage? {
        guard
            let imageData = UserDefaults.standard.data(forKey: imageStorageKey),
            let image = UIImage(data: imageData)
        else {
            return nil
        }

        return image
    }
}

#Preview {
    GrowthView()
}
