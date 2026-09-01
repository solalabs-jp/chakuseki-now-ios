import SwiftUI

/// マイページに表示する、ログイン中ユーザーの情報カードとログアウトボタン。
struct ProfileAccountSectionView: View {
    let profile: AuthService.Profile
    let onSignOut: () -> Void

    @State private var isConfirmingSignOut = false

    var body: some View {
        VStack(spacing: 16) {
            infoCard

            Button(role: .destructive) {
                isConfirmingSignOut = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("ログアウト")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(AppColors.statusAbsence)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.statusAbsence.opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .confirmationDialog("ログアウトしますか？", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
            Button("ログアウト", role: .destructive, action: onSignOut)
            Button("キャンセル", role: .cancel) {}
        }
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.brandRed.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Text(initials)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.brandRed)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name.isEmpty ? "名称未設定" : profile.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.labelPrimary)

                    Text(profile.roleLabel)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundColor(AppColors.brandRed)
                        .background(AppColors.brandRed.opacity(0.12))
                        .clipShape(Capsule())
                }

                Spacer()
            }
            .padding(16)

            Divider().padding(.horizontal, 16)

            infoRow(label: "メールアドレス", value: profile.email)
            if let number = profile.attendanceNumber, number > 0 {
                Divider().padding(.horizontal, 16)
                infoRow(label: "出席番号", value: "\(number)番")
            }
            if let classId = profile.classId, !classId.isEmpty {
                Divider().padding(.horizontal, 16)
                infoRow(label: "クラス", value: classId)
            }
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.cardBorder.opacity(0.3), lineWidth: 1)
        )
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppColors.labelSecondary)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.labelPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var initials: String {
        let trimmed = profile.name.trimmingCharacters(in: .whitespaces)
        guard let first = trimmed.first else { return "?" }
        return String(first)
    }
}

#Preview {
    ProfileAccountSectionView(
        profile: AuthService.Profile(
            userId: "student-001",
            uid: "abc123",
            name: "山田 太郎",
            role: "student",
            email: "student001@example.com",
            classId: "class-2A",
            attendanceNumber: 1
        ),
        onSignOut: {}
    )
    .padding()
}
