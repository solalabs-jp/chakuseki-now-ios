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
                    submittedAnswer = sentText
                    submittedTime = Date()
                    Task {
                        await checkIn.submitComment(sentText)
                        if checkIn.phase == .confirmed {
                            startMonitoring()
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
        if let errorMessage = checkIn.errorMessage {
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
            startMonitoring()
        }
        isRestoring = false
    }

    private func startMonitoring() {
        checkIn.startMonitoring(beaconLastSeen: { [beaconManager] in beaconManager.lastSeenAt })
    }

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
