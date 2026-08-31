import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore

/// Firebase Auth（メール／パスワード）と `users` コレクションの紐付けを担う。
///
/// 紐付けは `users` ドキュメントの `uid` フィールド（Firebase Auth の UID）で行う。
/// これによりドキュメント ID はスラッグ（`student-001` など）のまま、既存の
/// `attendanceRecords.userId` / `sessions.studentId` 等の FK を変更せずに済む。
@MainActor
@Observable
final class AuthService {
    static let shared = AuthService()

    struct Profile: Equatable {
        let userId: String       // users ドキュメント ID（例: "student-001"）
        let uid: String          // Firebase Auth UID
        let name: String
        let role: String         // "student" | "teacher"
        let email: String
        let classId: String?
        let attendanceNumber: Int?

        var isTeacher: Bool { role == "teacher" }
        var roleLabel: String { isTeacher ? "先生" : "生徒" }
    }

    enum Status: Equatable {
        case initializing
        case signedOut
        case signedIn(Profile)
        /// Auth 認証は通ったが、対応する users ドキュメントが見つからない。
        case profileMissing(uid: String, email: String?)
    }

    private(set) var status: Status = .initializing
    private(set) var isProcessing = false
    private(set) var errorMessage: String?

    private let db = Firestore.firestore()
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    private init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                await self?.resolve(user: user)
            }
        }
    }

    /// 現在ログイン中のユーザーの users ドキュメント ID。
    var currentUserId: String? {
        if case .signedIn(let profile) = status { return profile.userId }
        return nil
    }

    var currentProfile: Profile? {
        if case .signedIn(let profile) = status { return profile }
        return nil
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try await Auth.auth().signIn(withEmail: trimmedEmail, password: password)
            // 成功時は状態リスナー経由で status が更新される
        } catch {
            errorMessage = Self.localizedMessage(for: error)
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = Self.localizedMessage(for: error)
        }
    }

    // MARK: - Private

    private func resolve(user: User?) async {
        guard let user else {
            status = .signedOut
            return
        }

        do {
            let snapshot = try await db.collection("users")
                .whereField("uid", isEqualTo: user.uid)
                .limit(to: 1)
                .getDocuments()

            guard let document = snapshot.documents.first else {
                status = .profileMissing(uid: user.uid, email: user.email)
                return
            }

            let data = document.data()
            status = .signedIn(
                Profile(
                    userId: document.documentID,
                    uid: user.uid,
                    name: data["name"] as? String ?? "",
                    role: data["role"] as? String ?? "",
                    email: data["email"] as? String ?? user.email ?? "",
                    classId: data["classId"] as? String,
                    attendanceNumber: Self.intValue(data["attendanceNumber"])
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            status = .profileMissing(uid: user.uid, email: user.email)
        }
    }

    private static func intValue(_ value: Any?) -> Int? {
        switch value {
        case let int as Int: return int
        case let int64 as Int64: return Int(int64)
        case let number as NSNumber: return number.intValue
        case let string as String: return Int(string)
        default: return nil
        }
    }

    static func localizedMessage(for error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue,
            AuthErrorCode.invalidCredential.rawValue,
            AuthErrorCode.userNotFound.rawValue:
            return "メールアドレスまたはパスワードが正しくありません"
        case AuthErrorCode.invalidEmail.rawValue:
            return "メールアドレスの形式が正しくありません"
        case AuthErrorCode.userDisabled.rawValue:
            return "このアカウントは無効化されています"
        case AuthErrorCode.networkError.rawValue:
            return "ネットワークエラーが発生しました。通信環境を確認してください"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "試行回数が多すぎます。しばらく待ってから再度お試しください"
        default:
            return "ログインに失敗しました（コード: \(nsError.code)）"
        }
    }
}
