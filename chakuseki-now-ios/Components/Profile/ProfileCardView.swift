import PhotosUI
import SwiftUI

struct ProfileCardView: View {
    let levelTitle: String
    let levelProgress: CGFloat
    let remainingExpText: String

    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedProfileImage: UIImage? = ProfileImageStorage.load()

    init(
        levelTitle: String = "レベル〇〇",
        levelProgress: CGFloat = 0.42,
        remainingExpText: String = "進化まであと〇〇○EXP!"
    ) {
        self.levelTitle = levelTitle
        self.levelProgress = levelProgress
        self.remainingExpText = remainingExpText
    }

    var body: some View {
        ZStack(alignment: .top) {
            ProfileImagePickerButton(selectedImage: selectedProfileImage) {
                isPhotoPickerPresented = true
            }

            ProfileLevelSectionView(
                levelTitle: levelTitle,
                levelProgress: levelProgress,
                remainingExpText: remainingExpText
            )
        }
        .frame(maxWidth: .infinity, minHeight: 358, maxHeight: 358)
        .background(AppColors.white)
        .cornerRadius(12)
        .overlay(cardBorder)
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
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.5)
            .stroke(AppColors.cardBorder.opacity(0.3), lineWidth: 1)
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
        ProfileImageStorage.save(imageData)
    }
}

private enum ProfileImageStorage {
    private static let imageStorageKey = "growthView.profileImageData"

    static func save(_ imageData: Data) {
        UserDefaults.standard.set(imageData, forKey: imageStorageKey)
    }

    static func load() -> UIImage? {
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
    ProfileCardView()
        .padding()
}
