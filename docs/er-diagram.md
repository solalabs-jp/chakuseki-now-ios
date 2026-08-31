# ER図 — 着席なう データモデル

Firestore のコレクション設計の正本。最終更新: 2026-08-31

> コレクション名は camelCase（`users`, `attendanceRecords` など）。
> 下記エンティティ名（SNAKE_CASE）とフィールド名の対応・現状との差分は
> このファイル末尾の「実装との差分」を参照。

```mermaid
---
config:
  layout: elk
---
erDiagram
    direction TB
    USERS {
        string userId PK ""  
        string classId FK ""  
        string role  "student, teacher"  
        int attendanceNumber "出席番号"
        string name  ""  
        string email  ""  
        string fcmToken  "生徒のみ"  
        string beaconId  "先生のみ"
        timestamp createAt
        timestamp updateAt
    }

    CLASSES {
        string classId PK ""  
        string name  "例: 2024-A組"
        int entryYear "入学年"  
        timestamp createdAt  ""  
        timestamp updateAt ""
    }

    CHECKIN_QUESTIONS {
        string questionId PK ""  
        string sessionId FK ""  
        string teacherId FK ""  
        string questionText  "質問文"  
        boolean isSkippable  "スキップ可か"  
        timestamp sentAt  ""  
    }

    CHECKIN_ANSWERS {
        string answerId PK ""  
        string questionId FK ""  
        string attendance_reId FK ""  
        string userId FK ""  
        string answerText  "回答内容"  
        boolean isSkipped  "スキップ済み"  
        timestamp answeredAt  ""  
    }

    ATTENDANCE_OVERRIDES {
        string overrideId PK ""  
        string recordId FK ""  
        string teacherId FK ""  
        string previousStatus  "修正前"  
        string newStatus  "修正後"  
        string reason  "理由"  
        timestamp overriddenAt  "修正日時"  
    }

    SCHEDULES {
        string scheduleId PK ""  
        string classId FK ""  
        string defaultTeacherId FK "" 
        string periodId FK "" 
        string subjectName  ""  
        int dayOfWeek  "0=日〜6=土" 
        timestamp createdAt  "" 
        timestamp updateAt "" 
    }

    PERIODS {
        string periodId PK ""  
        int startAt  "hhmmの形式の四桁の数字"  
        int endAt  ""  
        int period  "何限目か" 
    }

    ATTENDANCE_RECORDS {
        string recordId PK ""  
        string sessionId FK ""  
        string userId FK ""  
        string status  "present|absent|late|early_leave|mid_absence|excused"  
        string detectionMethod  "ble|gps|manual"  
        timestamp firstDetectedAt  "初回検知時刻"  
        timestamp confirmedAt  "送信確定時刻"  
        timestamp lastDetectedAt  "最終検知時刻"  
        int absenceMinutes  "離席累計（分）"  
        boolean isExcused  "公欠フラグ"  
        string excusedReason  ""  
        timestamp excusedFrom  ""  
        timestamp excusedTo  ""  
    }

    DAILY_SESSIONS {
        string dailySessionsId PK ""  
        string scheduleId FK ""  
        string teacherId FK ""  
        timestamp date  "yyyy-mm-dd-00:00:00.00"  
        bool isIndoor  "trueで屋内授業"  
    }

    SESSIONS {
        string sessionId PK ""  
        string daily_sessionsId FK ""
        string studentId FK ""  
        string beaconId  "屋内用"  
        number gpsLat  "屋外: 緯度"  
        number gpsLng  "屋外: 経度"  
        timestamp createAt  ""  
    }

    USERS}o--||CLASSES:"所属する"
    USERS||--o{DAILY_SESSIONS:"担当する（先生）"
    USERS||--o{CHECKIN_QUESTIONS:"質問を送信する"
    USERS||--o{CHECKIN_ANSWERS:"回答する"
    USERS||--o{ATTENDANCE_OVERRIDES:"出席を修正する"
    CLASSES||--o{SCHEDULES:"時間割を持つ"
    SCHEDULES}o--||PERIODS:"時限を使用する"
    SCHEDULES||--o{DAILY_SESSIONS:"授業を生成する"
    DAILY_SESSIONS||--o{SESSIONS:"関連する"
    SESSIONS}o--||ATTENDANCE_RECORDS:"出席を記録する"
    DAILY_SESSIONS||--||CHECKIN_QUESTIONS:"質問を含む"
    ATTENDANCE_RECORDS||--o{ATTENDANCE_OVERRIDES:"修正されることがある"
    ATTENDANCE_RECORDS||--||CHECKIN_ANSWERS:"関連する"
    CHECKIN_QUESTIONS||--||CHECKIN_ANSWERS:"回答を受け取る"
```

## 前バージョンからの主な変更点

| エンティティ | 変更 |
|---|---|
| USERS | `gradeYear` を削除、`attendanceNumber`（出席番号）を追加。`createAt` / `updateAt` を追加 |
| CLASSES | `gradeYear` → **`entryYear`（入学年）**。`updateAt` を追加 |
| PERIODS | `startAt` / `endAt` が **timestamp → int（hhmm 4桁、例 `915`）** |
| DAILY_SESSIONS | 日付フィールド名 `timestamp` → **`date`** |
| SESSIONS | `scheduleId` を削除。FK は **`daily_sessionsId`** のみ（＋ `studentId`） |
| CHECKIN_ANSWERS | `sessionId` → **`attendance_reId`**（ATTENDANCE_RECORDS.recordId を参照） |
| SCHEDULES | `updateAt` を追加 |
| リレーション | DAILY_SESSIONS–CHECKIN_QUESTIONS、ATTENDANCE_RECORDS–CHECKIN_ANSWERS、CHECKIN_QUESTIONS–CHECKIN_ANSWERS が 1:1 に |

## 実装との差分（2026-08-31 反映済み）

Firestore データ・iOS コードともに上記ER図へ移行済み（移行スクリプト: scratchpad `migrate-er.mjs`）。

- `periods.startAt/endAt` … Timestamp → **Int（hhmm 例 `915`）**。`TimetableRepository.fetchPeriods` も Int 読み＋整形に変更
- `dailySessions` … 日付フィールド `timestamp` → **`date`**。`AttendanceCheckInService` も `date` を参照
- `sessions` … `scheduleId` 削除、`dailySessionsId` → **`daily_sessionsId`**。`AttendanceCheckInService` の書き込み・`TimetableRepository.fetchStatusByDay`（daily_sessionsId 経由で scheduleId 解決）を変更
- `checkinAnswers` … `sessionId` → **`attendance_reId`**（`attendanceRecords.recordId` 参照）。`AttendanceCheckInService` も対応
- `users` … `gradeYear` 削除、**`attendanceNumber`**（生徒: 出席番号）/ `createAt` / `updateAt` 追加。`AuthService.Profile` は `gradeYear` → `attendanceNumber`、マイページは「学年」→「出席番号」表示に変更
- `classes` … `gradeYear` → **`entryYear`（2025）**、`updateAt` 追加
- `schedules` … `updateAt` 追加

### ER 図に無い実装上の追加フィールド

- `users.uid` … Firebase Auth UID。Auth ⇔ users の紐付けに使用（[[firebase-setup]] 参照）
- 出席チェックインのドキュメント ID は決定論的（`{dailySessionId}__{userId}`, `rec_…`, `ans_…`）
