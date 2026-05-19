import PhotosUI
import SwiftUI

struct GrowthView: View {
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedProfileImage: UIImage? = GrowthView.loadSavedProfileImage()

    private static let imageStorageKey = "growthView.profileImageData"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("マイページ")
                    .font(.system(size: 24, weight: .bold))
                    .kerning(0.4)
                    .foregroundColor(Constants.LabelsVibrantPrimary)
                    .frame(width: 241, height: 41, alignment: .topLeading)

                Spacer()
            }

            ZStack(alignment: .top) {
                Button(action: { isPhotoPickerPresented = true }) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let selectedProfileImage {
                                Image(uiImage: selectedProfileImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 34, weight: .medium))
                                        .foregroundColor(Color(red: 0.72, green: 0.48, blue: 0.44))

                                    Text("画像を選択")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Constants.LabelsVibrantPrimary)

                                    Text("クリックしてアップロード")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(red: 0.99, green: 0.97, blue: 0.96))
                            }
                        }
                        .frame(width: 192, height: 192)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    selectedProfileImage == nil
                                    ? Color(red: 0.89, green: 0.75, blue: 0.72)
                                    : Color.clear,
                                    style: StrokeStyle(lineWidth: 1.5, dash: [7, 5])
                                )
                        )

                        if selectedProfileImage != nil {
                            Text("変更")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Capsule())
                                .padding(12)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 33)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 241)
                    .padding(.leading, 111)
            }
            .frame(maxWidth: .infinity, minHeight: 358, maxHeight: 358)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.89, green: 0.75, blue: 0.72).opacity(0.3), lineWidth: 1)
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
