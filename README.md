# chakuseki-now-ios 📱

「着席なう」の **生徒用 iOS アプリ**です。教卓に置いた BLE ビーコンを検知して出席チェックインを行い、
一言コメントの送信で出席を確定、授業終了まで在室を継続監視します。時間割・出席履歴カレンダーも
このアプリから確認できます。

教員・管理者向けの Web コンソール（`chakuseki-now-web`）と共通の Firebase プロジェクト
`chakuseki-now` を介して連携するサーバーレス構成です。全体像は以下のドキュメントを参照してください。

| ドキュメント | 内容 |
|---|---|
| [`docs/architecture.md`](docs/architecture.md) | システム構成図・クライアント別の詳細・データフロー |
| [`docs/spec.md`](docs/spec.md) | システム仕様書（出欠判定ロジック・機能要件・非機能要件） |
| [`docs/er-diagram.md`](docs/er-diagram.md) | Firestore コレクションの ER 図（mermaid） |

---

## 目次

- [主な機能](#主な機能)
- [技術スタック / 動作環境](#技術スタック--動作環境)
- [セットアップ手順](#セットアップ手順)
- [テスト用アカウント](#テスト用アカウント)
- [フォルダ構成](#フォルダ構成)
- [アーキテクチャ概要](#アーキテクチャ概要)
- [出席チェックインの流れ](#出席チェックインの流れ)
- [トラブルシューティング](#トラブルシューティング)
- [開発メモ / 既知の割り切り](#開発メモ--既知の割り切り)

---

## 主な機能

| 画面 | 概要 |
|---|---|
| **ログイン** | Firebase Auth（メール / パスワード）。`users` ドキュメントの `uid` フィールドでアカウントとプロフィールを紐付け。 |
| **ホーム** | ビーコン検索 → 検知 → 一言コメント送信で出席確定。確定後は授業終了まで在室を継続監視。アプリを閉じても再起動時に状態を復元。 |
| **時間割** | 当日の時間割を Firestore（`schedules` + `periods`）から構築し、各コマの出席ステータス（出席 / 遅刻 / 早退 / 中抜け / 予定）を表示。 |
| **マイページ** | プロフィール表示、成長（レベル）セクション、ログアウト。 |
| **出席履歴** | カレンダー形式で過去の出席ステータスを一覧。日別の詳細も参照可能。 |

出欠判定の詳細ルール（受付ウィンドウ、遅刻しきい値、30分離席判定など）は
[`docs/spec.md` 4.1](docs/spec.md) を参照してください。

---

## 技術スタック / 動作環境

- **言語 / UI**: Swift 5 / SwiftUI（`@Observable` ベースの状態管理、`@MainActor`）
- **バックエンド**: Firebase iOS SDK
  - `FirebaseAuth` … メール / パスワード認証
  - `FirebaseFirestore` … 単一の信頼できるデータソース（`asia-northeast1`）
  - `FirebaseCore` … `chakuseki_now_iosApp.init()` で `FirebaseApp.configure()`
- **BLE ビーコン**: CoreLocation（`CLLocationManager` の beacon ranging、複数 UUID 同時スキャン）
- **依存管理**: Swift Package Manager（`firebase-ios-sdk` 12.18.0 を pin。`Package.resolved` はコミット済み）

### 必要なもの

| 項目 | バージョン |
|---|---|
| macOS | Xcode が動作するバージョン |
| **Xcode** | **16.2 以降**（`firebase-ios-sdk` 12.x の要件。プロジェクトファイルは objectVersion 77 = Xcode 16 系フォーマット。基本はチームで使用中のバージョンに合わせる） |
| iOS デプロイターゲット | **17.6**（アプリ本体ターゲット） |
| ネットワーク | 初回ビルド時に GitHub から Firebase SDK を取得できること |

> [!IMPORTANT]
> このアプリは `chakuseki-now-mac` から **`chakuseki-now-ios` にリネーム済み**です。
> 開くべきプロジェクトは **`chakuseki-now-ios.xcodeproj`** です。古い名前のフォルダがローカルに
> 残っている場合は削除してください（[トラブルシューティング](#トラブルシューティング)参照）。

---

## セットアップ手順

### 1. リポジトリを取得する

```bash
git clone https://github.com/solalabs-jp/chakuseki-now-ios.git
cd chakuseki-now-ios
```

開発は `develop` ブランチで行います。

```bash
git checkout develop
```

### 2. Firebase 設定ファイルを配置する（必須）

`GoogleService-Info.plist` は **リポジトリに含まれていません**（`.gitignore` 済み）。
各自でローカルに配置する必要があります。

1. Firebase コンソール（プロジェクト `chakuseki-now`）→ プロジェクトの設定 → マイアプリ →
   iOS アプリ `jp.chakuseki-now-ios` から `GoogleService-Info.plist` をダウンロード
   （持っていない場合はチームの管理者に共有を依頼）。
2. ファイルを **`chakuseki-now-ios/` ディレクトリ直下**（`chakuseki_now_iosApp.swift` と同じ階層）に置く。

```
chakuseki-now-ios/
├── chakuseki_now_iosApp.swift
├── ContentView.swift
├── GoogleService-Info.plist   ← ここに置く
└── ...
```

> このプロジェクトは File System Synchronized Group を使っているため、ディレクトリに置けば
> 自動的にアプリターゲットへ含まれます（Xcode で手動追加する必要はありません）。
> 配置しないと起動時に `FirebaseApp.configure()` がクラッシュします。

### 3. Xcode でプロジェクトを開く

```bash
open chakuseki-now-ios.xcodeproj
```

（Finder で `chakuseki-now-ios.xcodeproj` をダブルクリックしても可）

### 4. Swift Package を解決する

初回は Xcode が自動で Firebase SDK を取得します（依存が多く数分かかります）。
`Missing package product 'FirebaseAuth'` などが出る場合は手動で解決します。

- メニュー `File → Packages → Resolve Package Versions`
- それでも直らなければ `File → Packages → Reset Package Caches` → 再度 Resolve

### 5. 実行する

1. Xcode 画面上部のデバイス選択から実行先を選ぶ（例: `iPhone 16` シミュレータ）。
   - このターゲットは **iOS 専用**です（`SUPPORTED_PLATFORMS = iphoneos iphonesimulator`）。`My Mac` は選べません。
2. `⌘R`（または左上の ▶ ボタン）でビルド＆実行。
3. 初回起動時、位置情報の許可を求められたら **「アプリの使用中は許可」** を選択
   （ビーコン検知に必要。拒否すると出席チェックインができません）。

> [!TIP]
> 物理的な BLE ビーコンが無い環境では、教卓ビーコンの UUID
> `01020304-0506-0708-090A-0B0C0D0E0F10` を送出する別デバイス（Mac の
> ビーコンシミュレータアプリ等）を用意すると検索画面のテストができます。
> このフォールバック UUID は「れんし」先生として表示されます。

---

## テスト用アカウント

Firebase Auth にシード済みのデモアカウントがあります（Firestore の `users` に対応ドキュメントあり）。

| 役割 | メールアドレス | 備考 |
|---|---|---|
| 生徒 | `student001@example.com` 〜 `student003@example.com` | `student-001` は class-2A、履歴・時間割データ投入済み |
| 教員 | `teacher001@example.com` 〜 `teacher002@example.com` | Web コンソール用（iOS では生徒アカウントを使用） |

共通パスワードはチームの管理者、または Firebase コンソール（Authentication）で確認してください
（README にはコミットしません）。

---

## フォルダ構成

```
chakuseki-now-ios/
├── chakuseki_now_iosApp.swift        アプリのエントリポイント。FirebaseApp.configure()
├── ContentView.swift                 auth.status で分岐（初期化中 / 未ログイン / ログイン済み / プロフィール無し）
│                                     ＋ MainTabView（ホーム / 時間割 / マイページ）
├── GoogleService-Info.plist          ※ 各自ローカル配置（gitignore 済み）
│
├── Views/                            画面単位のトップレベル View
│   ├── HomeView.swift                出席チェックイン画面（検索 → 確定 → 継続監視、状態復元）
│   ├── HistoryView.swift             時間割画面
│   ├── HistoryDetailView.swift       出席履歴の日別詳細
│   ├── GrowthView.swift              マイページ（プロフィール・レベル）
│   ├── LoginView.swift               ログイン
│   └── ForgotPasswordView.swift      パスワード再設定の案内
│
├── Components/                       画面を構成する再利用 View（機能ごとにサブフォルダ）
│   ├── Home/                         MessageInputField, HomeSearchingContentView,
│   │                                 HomeAttendanceContentView, AttendanceResultView,
│   │                                 StatusView, GreetingView, MainButton
│   ├── Calendar/                     CustomCalendarView, DayCellView
│   ├── History/                      出席履歴リスト・サマリーカード・ステータスバッジ
│   ├── Timetable/                    時間割の行・科目ボタン・日付表示
│   ├── Login/                        ログインカード・入力欄・タイトル
│   ├── Profile/                      プロフィールカード・画像ピッカー・レベル
│   └── Common/                       LeadingTitleView など横断的な部品
│
├── Services/                        Firestore 読み書きの実体（View から直接呼ぶ）
│   ├── AuthService.swift             Firebase Auth シングルトン。状態リスナー、uid → users 解決
│   ├── AttendanceCheckInService.swift ビーコン検知 → sessions/attendanceRecords 作成 →
│   │                                 コメントで status 確定 → 授業終了まで滞在監視
│   ├── TimetableRepository.swift     schedules + periods + (attendanceRecords × sessions) を join
│   └── AttendanceRepository.swift    出席履歴（attendanceRecords）取得
│
├── ViewModels/                      画面用の状態・ロード管理
│   ├── TimetableViewModel.swift
│   └── AttendanceHistoryViewModel.swift
│
├── Models/                         値型・スタイル定義・定数
│   ├── Attendance.swift              AttendanceStatus（present/absent/late/early_leave/mid_absence/excused。英語・日本語両対応）
│   ├── Timetable.swift              Timetable / TimetableSlot、JST タイムゾーン
│   ├── LoadState.swift              共通のロード状態 enum
│   ├── Constants.swift              AppColors（配色の一元定義）
│   ├── CalendarStyle.swift / TimetableStyle.swift
│
└── Managers/
    └── BeaconManager.swift          CoreLocation で複数 UUID を同時 ranging。
                                     検知後も止めず lastSeenAt を更新し続ける（継続監視用）

chakuseki-now-iosTests/              単体テストターゲット
chakuseki-now-iosUITests/            UI テストターゲット
chakuseki-now-ios.xcodeproj/         ← これを開く
docs/                                architecture.md / spec.md / er-diagram.md
```

---

## アーキテクチャ概要

MVVM 寄りの構成ですが、**単純な参照系は ViewModel を挟まず View から Service を直接呼ぶ**方針です。

```
View (SwiftUI)
  │  @Observable な Service / ViewModel を監視
  ▼
Service / Repository            AttendanceCheckInService / AuthService /
  │  Firestore クライアント SDK   TimetableRepository / AttendanceRepository
  ▼
Cloud Firestore (chakuseki-now, asia-northeast1)
```

- **認証**: `AuthService.shared`（`@Observable` シングルトン）が `Auth.auth().addStateDidChangeListener`
  で状態を監視。`status` は `initializing / signedOut / signedIn(Profile) / profileMissing`。
  `ContentView` がこれで画面を出し分けます。
- **プロフィール紐付け**: `users` ドキュメントの `uid` フィールド（Firebase Auth UID）で解決。
  ドキュメント ID はスラッグ（`student-001` など）のままなので、`attendanceRecords.userId` /
  `sessions.studentId` 等の FK を変更せずに済みます。
- **ビーコン**: `BeaconManager` は全教員の `beaconId`（複数 UUID）を同時 ranging。初回検知で画面遷移、
  以降も ranging を止めず `lastSeenAt` を更新し続け、継続監視の圏内 / 圏外判定に使います。
- **時刻はすべて JST 基準**（`Asia/Tokyo`）で算出します（`periods.startAt/endAt` は hhmm の Int）。

---

## 出席チェックインの流れ

`HomeView` ＋ `AttendanceCheckInService` が担います。

```
[検索] HomeSearchingContentView
   │  位置情報が許可されていれば全教員 beaconId を ranging
   │  （拒否時は「設定を開く」導線を表示）
   ▼ ビーコン検知
[確定前] handleBeaconDetected(uuid:)
   │  beaconId から教員特定 → 当日(JST)の dailySessions を
   │  「教員一致 × 自クラス × 現在時刻が受付ウィンドウ内」で厳密に特定
   │  （受付ウィンドウ = 開始 15 分前 〜 終了。範囲外は失敗・書き込みなし）
   │  sessions / attendanceRecords(status="absent") を決定論 ID で upsert
   ▼ 一言コメント送信（空送信 = スキップ可）
[確定] submitComment(_:)
   │  開始 15 分超なら status="late"、以内なら "present"。confirmedAt 記録。
   │  checkinAnswers 作成。送信失敗時は入力内容を保持したまま再送可能。
   ▼
[継続監視] startMonitoring → runMonitor（授業終了まで 60 秒間隔）
   │  圏内: lastDetectedAt 更新
   │  圏外: absenceMinutes 加算、連続 30 分でstatus="mid_absence"
   │  授業終了時点で圏外なら status="early_leave"
   │  ※ 測距ウォームアップ中／位置情報が未許可の間は「圏外」と断定せず判定を保留
   ▼
教員が Web コンソールで確認・修正（attendanceOverrides）
```

アプリを閉じて開き直した場合は `restoreActiveCheckIn()` が当日の該当授業を調べ、
コメント送信済み（`confirmedAt` あり）なら結果画面と継続監視を復元します。

---

## トラブルシューティング

### `... .xcodeproj cannot be opened because it is missing its project.pbxproj file.`

古い名前 `chakuseki-now-mac.xcodeproj` を開こうとしています。リネーム後、追跡対象の
`project.pbxproj` は削除されていますが、Xcode が作る未追跡サブフォルダが残るためディレクトリだけ
残存することがあります。

```bash
git checkout develop && git pull
rm -rf chakuseki-now-mac.xcodeproj chakuseki-now-mac
open chakuseki-now-ios.xcodeproj
```

### `Missing package product 'FirebaseAuth' / 'FirebaseFirestore'`

Swift Package が未解決です。リポジトリ側の設定（`project.pbxproj` の package 参照、`Package.resolved`）は
正しくコミットされています。

1. `File → Packages → Reset Package Caches` → `Resolve Package Versions`
2. 直らなければ Xcode を終了して以下を削除し、開き直す
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   rm -rf ~/Library/Caches/org.swift.swiftpm
   ```
3. **Xcode 16.2 以降**であること、GitHub（`github.com/firebase`）へ到達できることを確認

### 起動直後にクラッシュする

`GoogleService-Info.plist` が `chakuseki-now-ios/` 直下に配置されていません。
[セットアップ手順 2](#2-firebase-設定ファイルを配置する必須) を参照。

### 出席チェックインの検索画面から進まない

位置情報が「許可しない」になっています。検索画面の「設定を開く」から設定アプリで
位置情報を許可してください。許可されていない間は継続監視も開始されません。

### 時間割に他クラスの授業が混ざる

`users` ドキュメントに `classId` が設定されていないアカウントです（未設定時は空の時間割を返します）。
Firebase コンソールで対象ユーザーの `classId` を設定してください。

---

## 開発メモ / 既知の割り切り

- **Firestore セキュリティルール**: `sessions` / `attendanceRecords` / `checkinAnswers` は
  `allow create, update: if request.auth != null`。他は `read: if true` / `write: if false`。
  `read` の厳格化は Web 側の Auth 対応まで保留。
- **継続監視は前面のみ**: ホームタブ滞在中にのみ動作します（バックグラウンド ranging は未実装）。
  テスト時は `AttendanceCheckInService` の `absenceThresholdSeconds` を小さくして確認します。
- **`HistoryDetailView`** は科目で絞らず、そのユーザーの全 `attendanceRecords` を表示します。
- **`statusByDay`** は (日, 科目) キーのため、同日に同科目の出席レコードが複数あると最後の 1 件で上書きされます。
- **`CustomCalendarView.statuses(for:)`** に一部ハードコードが残っています。
- **テストデータ**: `dailySessions` は今日から数週間分しか投入されていないため、期間を過ぎたら
  シードスクリプトの再実行が必要です（class-2A に月〜金 × 1〜6 限を投入済み。詳細はチーム内共有の seed スクリプト参照）。
- サインアップ画面は未実装（ログインのみ。アカウントはシード / Web コンソールで作成）。
