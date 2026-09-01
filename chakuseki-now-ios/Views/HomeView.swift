import SwiftUI
import UIKit

struct HomeView: View {
    let resetTrigger: Int

    @State private var currentStatus: StatusView.Status = .searching
    @State private var submittedAnswer: String? = nil
    @State private var submittedTime: Date? = nil
    @State private var detectedUUID: UUID? = nil
    @State private var isRestoring = true
    @State private var checkIn = AttendanceCheckInService()
    @StateObject private var beaconManager = BeaconManager()

    /// 教員ビーコンが1つも取得できなかった場合のフォールバック（検索UIと揃える）。
    private let fallbackBeaconUUID = UUID(uuidString: "01020304-0506-0708-090A-0B0C0D0E0F10")

    var teacherName: String? {
        if let resolved = checkIn.teacherName, !resolved.isEmpty {
            return resolved
        }
        guard let uuidString = detectedUUID?.uuidString.uppercased() else { return nil }
        if uuidString == "01020304-0506-0708-090A-0B0C0D0E0F10" {
            return "れんし"
        }
        return nil
    }

    /// 送信済みの場合の確定ステータス（出席/遅刻/早退/中抜け）。枠線・バッジの色に使う。
    private var attendanceStatus: AttendanceStatus? {
        guard submittedAnswer != nil, let raw = checkIn.confirmedStatus else { return nil }
        return AttendanceStatus(firestoreValue: raw)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GreetingView(isAttended: submittedAnswer != nil)

            StatusView(
                status: currentStatus,
                isAttended: submittedAnswer != nil,
                teacherName: teacherName,
                attendanceStatus: attendanceStatus
            )
                .padding(.top, 61)

            if isRestoring {
                Spacer()
                ProgressView()
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if currentStatus == .searching {
                Spacer()

                HomeSearchingContentView(
                    beaconManager: beaconManager,
                    beaconUUIDsProvider: { await checkIn.fetchTeacherBeaconUUIDs() }
                ) { uuid in
                    detectedUUID = uuid
                    currentStatus = .connecting
                    Task { await checkIn.handleBeaconDetected(uuid: uuid) }
                }

                Spacer()
            } else {
                HomeAttendanceContentView(
                    submittedAnswer: submittedAnswer,
                    submittedTime: submittedTime
                ) { sentText in
                    let previousAnswer = submittedAnswer
                    let previousTime = submittedTime
                    submittedAnswer = sentText
                    submittedTime = Date()
                    Task {
                        await checkIn.submitComment(sentText)
                        if checkIn.phase == .confirmed {
                            startMonitoring()
                        } else {
                            // 送信失敗（オフライン等で phase = .failed）: 楽観的更新を元に戻し、
                            // 入力欄を再表示して再送可能にする。
                            submittedAnswer = previousAnswer
                            submittedTime = previousTime
                        }
                    }
                }
                .padding(.top, 24)

                statusMessage
                    .padding(.top, 12)

                Spacer()
            }
        }
        .padding(.top, 1.5)
        .padding(.horizontal)
        .padding(.bottom)
        .contentShape(Rectangle())
        .onTapGesture {
            // 入力欄以外をタップしたらキーボードを閉じる
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
            )
        }
        .task {
            await restoreOrSearch()
        }
        .onChange(of: resetTrigger) { _, _ in
            Task { await resetToFirstPage() }
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        if beaconManager.permissionDenied {
            message("位置情報が許可されていないため滞在確認ができません。設定アプリで許可してください。", color: AppColors.statusAbsence)
        } else if let errorMessage = checkIn.errorMessage {
            message(errorMessage, color: AppColors.statusAbsence)
        } else if checkIn.confirmedStatus == "mid_absence" || checkIn.confirmedStatus == "early_leave" {
            message(checkIn.monitorInfo ?? "自動判定フラグあり（先生の承認・修正待ち）", color: AppColors.statusAbsence)
        } else if checkIn.confirmedStatus == "late" {
            message("遅刻として記録しました（先生の承認・修正待ち）", color: AppColors.statusTardiness)
        } else if let info = checkIn.monitorInfo {
            message(info, color: AppColors.labelSecondary)
        }
    }

    private func message(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    /// アプリ起動 / ホームタブ再選択時: 送信済みなら結果画面を復元、なければ検索から開始。
    private func restoreOrSearch() async {
        isRestoring = true
        if let restored = await checkIn.restoreActiveCheckIn() {
            submittedAnswer = restored.answer
            submittedTime = restored.time
            detectedUUID = nil
            currentStatus = .connecting
            // 復元経路では検索UI(HomeSearchingContentView)が表示されないため、
            // ここで明示的に測距を開始しないと beaconManager.lastSeenAt が nil のままになり、
            // 滞在監視が毎ハートビート「圏外」判定となって在室中の生徒の記録を破壊。
            await startBeaconScan()
            // 位置情報権限が拒否されていると測距が始まらず lastSeenAt が nil のままになる。
            // その状態で監視を回すと在室中でも mid_absence / early_leave を書き込むため開始しない
            // （権限が付与され次第、次回の restoreOrSearch で開始される）。
            if !beaconManager.permissionDenied {
                startMonitoring()
            }
        }
        isRestoring = false
    }

    /// 教員ビーコンの測距を開始。取得できなければフォールバック UUID を使う
    private func startBeaconScan() async {
        var uuids = await checkIn.fetchTeacherBeaconUUIDs()
        if uuids.isEmpty, let fallbackBeaconUUID {
            uuids = [fallbackBeaconUUID]
        }
        beaconManager.start(uuids: uuids)
    }

    /// 滞在監視を開始（監視は生徒ごとのバックグラウンドタスクで独立して動作）
    private func startMonitoring() {
        checkIn.startMonitoring(
            beaconLastSeen: { [beaconManager] in beaconManager.lastSeenAt },
            rangingBlocked: { [beaconManager] in beaconManager.permissionDenied }
        )
    }

    /// ホームタブ再選択時: 送信済みなら結果画面を復元、なければ検索から開始
    private func resetToFirstPage() async {
        checkIn.reset()
        beaconManager.stop()
        submittedAnswer = nil
        submittedTime = nil
        detectedUUID = nil
        currentStatus = .searching
        await restoreOrSearch()
    }
}

#Preview {
    HomeView(resetTrigger: 0)
}
