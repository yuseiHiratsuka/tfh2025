# ゴール指向絵しりとりアプリ - データベース設計書

## 1. Firestore コレクション構造

### 1.1 全体構造

```
/rooms/{roomId}
  ├─ /participants/{userId}
  └─ /submissions/{submissionId}
```

---

## 2. コレクション詳細

### 2.1 /rooms/{roomId}

**概要:** ゲームルームの情報を管理

**フィールド定義:**

| フィールド名 | 型 | 必須 | 説明 | 例 |
|------------|---|------|------|---|
| id | string | ○ | ドキュメントID | "room123" |
| createdAt | Timestamp | ○ | 作成日時 | 2024-01-01 10:00:00 |
| updatedAt | Timestamp | ○ | 更新日時 | 2024-01-01 10:05:00 |
| status | string | ○ | ゲーム状態 | "playing" |
| failureReason | string \| null | △ | 失敗理由（'timeout' / 'max_turns' / 'giveup' など） | null |
| startCharacter | string | ○ | 開始文字（1文字、ひらがな） | "り" |
| goalCharacter | string | ○ | ゴール文字（1文字、ひらがな） | "き" |
| maxPlayers | number | ○ | 最大参加人数 | 10 |
| timeLimit | number | ○ | 全体の制限時間（秒） | 120 |
| startedAt | Timestamp \| null | ○ | ゲーム開始日時 | 2024-01-01 10:00:00 |
| currentCharacter | string | ○ | 現在のお題文字（1文字、ひらがな） | "ご" |
| currentSequence | number | ○ | シーケンス番号（楽観的ロック用） | 3 |
| usedWords | string[] | ○ | 使用済みワード配列 | ["りんご", "ごりら", "らっぱ"] |
| chainCount | number | ○ | チェーン数（採用された回数） | 3 |
| isGoalReached | boolean | ○ | ゴール到達フラグ | false |
| goalReachedBy | string \| null | ○ | ゴール到達者のuserId | null |
| finishedAt | Timestamp \| null | ○ | 終了日時 | null |
| score | number \| null | ○ | ゲームスコア | null |
| timeBonus | number \| null | △ | 時間ボーナス（オプション） | null |
| chainBonus | number \| null | △ | チェーンボーナス（オプション） | null |
| totalSubmissions | number | ○ | 総投稿数 | 15 |
| totalParticipants | number | ○ | 総参加者数 | 4 |
| readyCount | number | ○ | 準備完了している参加者数 | 2 |

**status の値:**
- `waiting`: 参加者募集中
- `presenting`: お題提示中（マスターが開始を押した後、全員準備完了待ち）
- `playing`: ゲーム進行中
- `success`: クリア
- `failed`: 失敗（タイムアウトなど）

`status` が `failed` の場合には、`failureReason` にタイムアウトや最大ターン到達など、より具体的な失敗理由を格納してもよい。

**スコア計算の方針:**

- `status` が `success` の場合: `score = timeBonus + chainBonus` として保存する。
- `status` が `failed` の場合: `score` は常に `0` とし、`chainBonus` にチェーン数に応じた値（例: `chainCount * 1000`）を保存してもよい。

**インデックス:**
```
単一フィールドインデックス:
- status (ASC)
- createdAt (DESC)

複合インデックス:
- status (ASC), createdAt (DESC)
```

**初期値例（ルーム作成時）:**
```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:00Z",
  "status": "waiting",
  "failureReason": null,
  
  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": null,
  
  "currentCharacter": "り",
  "currentSequence": 0,
  "usedWords": [],
  "chainCount": 0,
  
  "isGoalReached": false,
  "goalReachedBy": null,
  "finishedAt": null,
  
  "score": null,
  "timeBonus": null,
  "chainBonus": null,
  
  "totalSubmissions": 0,
  "totalParticipants": 0
}
```

**お題提示時の例:**
```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:25Z",
  "status": "presenting",
  "failureReason": null,
  
  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": null,
  
  "currentCharacter": "り",
  "currentSequence": 0,
  "usedWords": [],
  "chainCount": 0,
  
  "isGoalReached": false,
  "goalReachedBy": null,
  "finishedAt": null,
  
  "score": null,
  "timeBonus": null,
  "chainBonus": null,
  
  "totalSubmissions": 0,
  "totalParticipants": 4,
  "readyCount": 0
}
```

**ゲーム開始時の例:**
```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:30Z",
  "status": "playing",
  "failureReason": null,
  
  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": "2024-01-01T10:00:30Z",
  
  "currentCharacter": "り",
  "currentSequence": 0,
  "usedWords": [],
  "chainCount": 0,
  
  "isGoalReached": false,
  "goalReachedBy": null,
  "finishedAt": null,
  
  "score": null,
  "timeBonus": null,
  "chainBonus": null,
  
  "totalSubmissions": 0,
  "totalParticipants": 4,
  "readyCount": 4
}
```

**ゲーム進行中の例:**
```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:01:45Z",
  "status": "playing",
  "failureReason": null,
  
  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": "2024-01-01T10:00:30Z",
  
  "currentCharacter": "ぱ",
  "currentSequence": 3,
  "usedWords": ["りんご", "ごりら", "らっぱ"],
  "chainCount": 3,
  
  "isGoalReached": false,
  "goalReachedBy": null,
  "finishedAt": null,
  
  "score": null,
  "timeBonus": null,
  "chainBonus": null,
  
  "totalSubmissions": 12,
  "totalParticipants": 4
}
```

**クリア時の例:**
```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:01:15Z",
  "status": "success",
  "failureReason": null,
  
  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": "2024-01-01T10:00:30Z",
  
  "currentCharacter": "き",
  "currentSequence": 6,
  "usedWords": ["りんご", "ごりら", "らっぱ", "ぱんだ", "だるま", "まき"],
  "chainCount": 6,
  
  "isGoalReached": true,
  "goalReachedBy": "anonymous_abc123",
  "finishedAt": "2024-01-01T10:01:15Z",
  
  "score": 9750,
  "timeBonus": 3750,
  "chainBonus": 6000,
  
  "totalSubmissions": 25,
  "totalParticipants": 4
}
```

**タイムアウト失敗時の例:**
```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:02:30Z",
  "status": "failed",
  "failureReason": "timeout",

  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": "2024-01-01T10:00:30Z",
  
  "currentCharacter": "だ",
  "currentSequence": 4,
  "usedWords": ["りんご", "ごりら", "らっぱ", "ぱんだ"],
  "chainCount": 4,
  
  "isGoalReached": false,
  "goalReachedBy": null,
  "finishedAt": "2024-01-01T10:02:30Z",
  
  "score": 0,
  "timeBonus": 0,
  "chainBonus": 4000,
  
  "totalSubmissions": 18,
  "totalParticipants": 4
}
```

---

### 2.2 /rooms/{roomId}/participants/{userId}

**概要:** ルームの参加者情報を管理

**フィールド定義:**

| フィールド名 | 型 | 必須 | 説明 | 例 |
|------------|---|------|------|---|
| userId | string | ○ | ユーザーID（匿名認証のUID） | "anonymous_abc123" |
| displayName | string | ○ | 表示名 | "プレイヤー1234" |
| avatarUrl | string \| null | ○ | アバター画像URL | null |
| joinedAt | Timestamp | ○ | 参加日時 | 2024-01-01 10:00:10 |
| lastSubmittedAt | Timestamp \| null | ○ | 最後の投稿日時 | 2024-01-01 10:01:05 |
| isReady | boolean | ○ | 準備完了フラグ | false |
| isMaster | boolean | ○ | ルームマスターかどうか | false |
| isAI | boolean | ○ | AI参加者かどうか | false |

**インデックス:**
```
単一フィールドインデックス:
- joinedAt (ASC)
```

**初期値例（参加時）:**
```json
{
  "userId": "anonymous_abc123",
  "displayName": "プレイヤー1234",
  "avatarUrl": null,
  "joinedAt": "2024-01-01T10:00:10Z",
  "lastSubmittedAt": null,
  "isReady": false,
  "isMaster": false
}
```

**投稿後の例:**
```json
{
  "userId": "anonymous_abc123",
  "displayName": "プレイヤー1234",
  "avatarUrl": null,
  "joinedAt": "2024-01-01T10:00:10Z",
  "lastSubmittedAt": "2024-01-01T10:01:05Z",
  "isReady": false,
  "isMaster": false
}
```

**マスター参加者の例:**
```json
{
  "userId": "anonymous_xyz789",
  "displayName": "マスター",
  "avatarUrl": null,
  "joinedAt": "2024-01-01T10:00:05Z",
  "lastSubmittedAt": null,
  "isReady": false,
  "isMaster": true
}
```

---

### 2.3 /rooms/{roomId}/submissions/{submissionId}

**概要:** 投稿された絵の情報を管理

**フィールド定義:**

| フィールド名 | 型 | 必須 | 説明 | 例 |
|------------|---|------|------|---|
| id | string | ○ | ドキュメントID | "sub123" |
| userId | string | ○ | 投稿者ID | "anonymous_abc123" |
| userName | string | ○ | 投稿者名（非正規化） | "プレイヤー1234" |
| createdAt | Timestamp | ○ | 投稿日時 | 2024-01-01 10:00:35 |
| sequenceNumber | number | ○ | 投稿時のシーケンス番号 | 0 |
| imageUrl | string | ○ | Storage公開URL | "https://storage.googleapis..." |
| storagePath | string | ○ | Storage内パス | "rooms/room123/..." |
| status | string | ○ | 処理状態 | "completed" |
| aiResult | object \| null | ○ | AI認識結果 | {...} |
| validation | object \| null | ○ | 検証結果 | {...} |

**status の値:**
- `processing`: AI認識中
- `completed`: AI認識完了
- `failed`: AI認識失敗

**aiResult オブジェクト:**

| フィールド名 | 型 | 必須 | 説明 | 例 |
|------------|---|------|------|---|
| word | string | ○ | 認識された単語（ひらがな） | "りんご" |
| firstChar | string | ○ | 最初の文字（ひらがな1文字） | "り" |
| lastChar | string | ○ | 最後の文字（ひらがな1文字） | "ご" |
| recognizedAt | Timestamp | ○ | 認識完了日時 | 2024-01-01 10:00:40 |

**validation オブジェクト:**

| フィールド名 | 型 | 必須 | 説明 | 例 |
|------------|---|------|------|---|
| isValid | boolean | ○ | しりとりとして正しいか | true |
| isAdopted | boolean | ○ | 採用されたか | true |
| isGoalReached | boolean | ○ | ゴール到達か | false |
| reasonCode | string \| null | △ | 不採用/不正解理由のコード値（'start_char_mismatch' など） | null |
| reason | string \| null | ○ | 不採用/不正解の理由 | null |
| adoptionOrder | number \| null | ○ | 採用順序（1始まり） | 1 |
| validatedAt | Timestamp | ○ | 検証完了日時 | 2024-01-01 10:00:42 |

**reasonCode の例:**

- `start_char_mismatch`: 開始文字が一致しない
- `ends_with_n`: 「ん」で終わる単語
- `word_duplicated`: 過去に使用された単語
- `min_turns_not_reached`: 最低ターン数に達していない
- `already_advanced`: 既に次のお題に進んでいる

**インデックス:**
```
単一フィールドインデックス:
- createdAt (DESC)
- sequenceNumber (ASC)

複合インデックス:
- userId (ASC), createdAt (DESC)
- validation.isAdopted (ASC), validation.adoptionOrder (ASC)
```

**投稿直後の例:**
```json
{
  "id": "sub123",
  "userId": "anonymous_abc123",
  "userName": "プレイヤー1234",
  "createdAt": "2024-01-01T10:00:35Z",
  "sequenceNumber": 0,
  
  "imageUrl": "https://storage.googleapis.com/project.appspot.com/rooms/room123/submissions/anonymous_abc123_1704096035000.jpg",
  "storagePath": "rooms/room123/submissions/anonymous_abc123_1704096035000.jpg",
  
  "status": "processing",
  "aiResult": null,
  "validation": null
}
```

**AI認識完了後の例:**
```json
{
  "id": "sub123",
  "userId": "anonymous_abc123",
  "userName": "プレイヤー1234",
  "createdAt": "2024-01-01T10:00:35Z",
  "sequenceNumber": 0,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_abc123_1704096035000.jpg",
  
  "status": "completed",
  "aiResult": {
    "word": "りんご",
    "firstChar": "り",
    "lastChar": "ご",
    "recognizedAt": "2024-01-01T10:00:40Z"
  },
  "validation": null
}
```

**検証完了（採用）の例:**
```json
{
  "id": "sub123",
  "userId": "anonymous_abc123",
  "userName": "プレイヤー1234",
  "createdAt": "2024-01-01T10:00:35Z",
  "sequenceNumber": 0,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_abc123_1704096035000.jpg",
  
  "status": "completed",
  "aiResult": {
    "word": "りんご",
    "firstChar": "り",
    "lastChar": "ご",
    "recognizedAt": "2024-01-01T10:00:40Z"
  },
  "validation": {
    "isValid": true,
    "isAdopted": true,
    "isGoalReached": false,
    "reasonCode": null,
    "reason": null,
    "adoptionOrder": 1,
    "validatedAt": "2024-01-01T10:00:42Z"
  }
}
```

**検証完了（不採用 - タイミング遅延）の例:**
```json
{
  "id": "sub124",
  "userId": "anonymous_def456",
  "userName": "プレイヤー5678",
  "createdAt": "2024-01-01T10:00:36Z",
  "sequenceNumber": 0,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_def456_1704096036000.jpg",
  
  "status": "completed",
  "aiResult": {
    "word": "りす",
    "firstChar": "り",
    "lastChar": "す",
    "recognizedAt": "2024-01-01T10:00:43Z"
  },
  "validation": {
    "isValid": true,
    "isAdopted": false,
    "isGoalReached": false,
    "reasonCode": "already_advanced",
    "reason": "既に次のお題に進んでいます",
    "adoptionOrder": null,
    "validatedAt": "2024-01-01T10:00:45Z"
  }
}
```

**検証完了（不正解 - 開始文字不一致）の例:**
```json
{
  "id": "sub125",
  "userId": "anonymous_ghi789",
  "userName": "プレイヤー9012",
  "createdAt": "2024-01-01T10:00:37Z",
  "sequenceNumber": 0,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_ghi789_1704096037000.jpg",
  
  "status": "completed",
  "aiResult": {
    "word": "ねこ",
    "firstChar": "ね",
    "lastChar": "こ",
    "recognizedAt": "2024-01-01T10:00:41Z"
  },
  "validation": {
    "isValid": false,
    "isAdopted": false,
    "isGoalReached": false,
    "reasonCode": "start_char_mismatch",
    "reason": "「り」から始まる絵を描いてください（「ね」から始まっています）",
    "adoptionOrder": null,
    "validatedAt": "2024-01-01T10:00:43Z"
  }
}
```

**検証完了（不正解 - 最低ターン数）の例:**
```json
{
  "id": "sub126",
  "userId": "anonymous_abc123",
  "userName": "プレイヤー1234",
  "createdAt": "2024-01-01T10:00:35Z",
  "sequenceNumber": 0,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_abc123_1704096035000.jpg",
  
  "status": "completed",
  "aiResult": {
    "word": "りんご",
    "firstChar": "り",
    "lastChar": "ご",
    "recognizedAt": "2024-01-01T10:00:40Z"
  },
  "validation": {
    "isValid": false,
    "isAdopted": false,
    "isGoalReached": false,
    "reasonCode": "min_turns_not_reached",
    "reason": "最低3ターン必要です（現在1ターン目）",
    "adoptionOrder": null,
    "validatedAt": "2024-01-01T10:00:42Z"
  }
}
```
※開始「り」、ゴール「ご」の場合の1ターン目

**ゴール到達の例:**
```json
{
  "id": "sub130",
  "userId": "anonymous_abc123",
  "userName": "プレイヤー1234",
  "createdAt": "2024-01-01T10:01:10Z",
  "sequenceNumber": 5,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_abc123_1704096070000.jpg",
  
  "status": "completed",
  "aiResult": {
    "word": "まき",
    "firstChar": "ま",
    "lastChar": "き",
    "recognizedAt": "2024-01-01T10:01:13Z"
  },
  "validation": {
    "isValid": true,
    "isAdopted": true,
    "isGoalReached": true,
    "reasonCode": null,
    "reason": null,
    "adoptionOrder": 6,
    "validatedAt": "2024-01-01T10:01:15Z"
  }
}
```

**AI認識失敗の例:**
```json
{
  "id": "sub127",
  "userId": "anonymous_jkl012",
  "userName": "プレイヤー3456",
  "createdAt": "2024-01-01T10:00:50Z",
  "sequenceNumber": 1,
  
  "imageUrl": "https://storage.googleapis.com/...",
  "storagePath": "rooms/room123/submissions/anonymous_jkl012_1704096050000.jpg",
  
  "status": "failed",
  "aiResult": null,
  "validation": null
}
```

---

## 3. Firebase Storage 構造

### 3.1 画像ファイルパス

**パス形式:**
```
/rooms/{roomId}/submissions/{userId}_{timestamp}.jpg
```

**具体例:**
```
/rooms/room123/submissions/anonymous_abc123_1704096035000.jpg
```

**命名規則:**
- `{roomId}`: ルームID
- `{userId}`: 投稿者のユーザーID（匿名認証UID）
- `{timestamp}`: ミリ秒単位のタイムスタンプ
- 拡張子: `.jpg` 固定

**ファイル仕様:**
- 形式: JPEG
- 最大サイズ: 5MB
- 推奨サイズ: 100KB程度（圧縮後）
- 推奨解像度: 長辺800px

---

## 4. データフロー

### 4.1 ルーム作成フロー

```
1. クライアント
   ↓ 
   Firestore.collection('rooms').add({
     status: 'waiting',
     startCharacter: 'り',
     goalCharacter: 'き',
     maxPlayers: 10,
     timeLimit: 120,
     startedAt: null,
     currentSequence: 0,
     chainCount: 0,
     usedWords: [],
     ...
   })
   
2. /rooms/{roomId} ドキュメント作成完了
```

### 4.2 参加フロー

```
1. クライアント
   ↓
   参加者数を確認
   isMaster = (totalParticipants == 0)  // 最初の参加者がマスター
   ↓
   Firestore.collection('rooms/{roomId}/participants').doc(userId).set({
     userId: userId,
     displayName: displayName,
     joinedAt: Timestamp.now(),
     lastSubmittedAt: null,
     isReady: false,
     isMaster: isMaster
   })
   
2. /rooms/{roomId}/participants/{userId} ドキュメント作成完了
   
3. クライアント
   ↓
   Firestore.doc('rooms/{roomId}').update({
     totalParticipants: FieldValue.increment(1)
   })
   
4. /rooms/{roomId}.totalParticipants が +1
```

### 4.3 お題提示と準備完了フロー

```
1. クライアント（マスター）
   ↓ ゲーム開始ボタンを押す
   Firestore.doc('rooms/{roomId}').update({
     status: 'presenting',
     readyCount: 0
   })
   ↓
   全参加者のisReadyをfalseにリセット

2. クライアント（各参加者）
   ↓ お題提示画面で準備ボタンを押す
   Firestore.doc('rooms/{roomId}/participants/{userId}').update({
     isReady: true
   })
   ↓
   Firestore.doc('rooms/{roomId}').update({
     readyCount: FieldValue.increment(1)
   })

3. 全参加者が準備完了（readyCount == totalParticipants）のとき
   ↓（トランザクション内で判定）
   Firestore.doc('rooms/{roomId}').update({
     status: 'playing',
     startedAt: Timestamp.now()
   })
```

### 4.4 お題提示状態の例

```json
{
  "id": "room123",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:25Z",
  "status": "presenting",
  "failureReason": null,
  
  "startCharacter": "り",
  "goalCharacter": "き",
  "maxPlayers": 10,
  "timeLimit": 120,
  "startedAt": null,
  
  "currentCharacter": "り",
  "currentSequence": 0,
  "usedWords": [],
  "chainCount": 0,
  
  "isGoalReached": false,
  "goalReachedBy": null,
  "finishedAt": null,
  
  "score": null,
  "timeBonus": null,
  "chainBonus": null,
  
  "totalSubmissions": 0,
  "totalParticipants": 4,
  "readyCount": 2
}
```

### 4.5 投稿フロー

```
1. クライアント
   ↓ 画像を圧縮
   ↓ Storage.ref(storagePath).putFile(imageFile)
   
2. Firebase Storage に画像保存
   
3. クライアント
   ↓ imageUrl = Storage.ref(storagePath).getDownloadURL()
   ↓ 
   roomSnapshot = Firestore.doc('rooms/{roomId}').get()
   currentSequence = roomSnapshot.data.currentSequence
   ↓
   Firestore.collection('rooms/{roomId}/submissions').add({
     userId: userId,
     userName: userName,
     createdAt: Timestamp.now(),
     sequenceNumber: currentSequence,
     imageUrl: imageUrl,
     storagePath: storagePath,
     status: 'processing',
     aiResult: null,
     validation: null
   })
   
4. /rooms/{roomId}/submissions/{submissionId} ドキュメント作成

5. Cloud Functions: processSubmissionImage トリガー（onCreate）
   ↓ 
   Gemini Vision API 呼び出し(wordだけ生成)
   ↓
   AI結果を元にfirstCharとlastChar,recognizedAtを生成
   ↓
   Firestore.doc('rooms/{roomId}/submissions/{submissionId}').update({
     status: 'completed',
     aiResult: {
       word: 'りんご',
       firstChar: 'り',
       lastChar: 'ご',
       recognizedAt: Timestamp.now()
     }
   })
   
6. /rooms/{roomId}/submissions/{submissionId} 更新（aiResult追加）

7. Cloud Functions: validateAndAdoptSubmission トリガー（onUpdate）
   ↓
   トランザクション開始
   ↓
   roomドキュメント取得
   ↓
   シーケンス番号チェック
   ↓
   しりとり判定
   ↓
   採用判定
   ↓
  room更新（採用の場合）:
    - currentSequence: +1
    - currentCharacter: aiResult.lastChar
    - usedWords: + aiResult.word
    - chainCount: +1
    - ゴール判定（採用後の chainCount >= 3 かつ aiResult.lastChar == goalCharacter）
    - スコア計算（ゴール時のみ）
   ↓
   participant更新:
     - lastSubmittedAt: Timestamp.now()
   ↓
   トランザクション終了
   ↓
   Firestore.doc('rooms/{roomId}/submissions/{submissionId}').update({
     validation: {
       isValid: true,
       isAdopted: true,
       isGoalReached: false,
       reason: null,
       adoptionOrder: 1,
       validatedAt: Timestamp.now()
     }
   })
   
8. /rooms/{roomId}/submissions/{submissionId} 更新（validation追加）

9. クライアント
   ↓ リアルタイムリスナーで変更を検知
   ↓ UI更新
```

### 4.6 タイムアウトフロー

```
1. クライアント側タイマーが制限時間到達
   ↓
   Firestore.doc('rooms/{roomId}').update({
     status: 'failed',
     finishedAt: Timestamp.now(),
     score: 0,
     timeBonus: 0,
     chainBonus: chainCount * 1000
   })
   
2. /rooms/{roomId} 更新完了
   
3. クライアント
   ↓ UI に「タイムアップ」表示
```

---

## 5. クエリパターン

### 5.1 ルーム関連

**参加可能なルーム一覧取得:**
```typescript
db.collection('rooms')
  .where('status', '==', 'waiting')
  .orderBy('createdAt', 'desc')
  .limit(20)
  .get()
```

**進行中のルーム一覧取得:**
```typescript
db.collection('rooms')
  .where('status', '==', 'playing')
  .orderBy('createdAt', 'desc')
  .limit(20)
  .get()
```

**完了したルーム一覧取得（スコア順）:**
```typescript
db.collection('rooms')
  .where('status', '==', 'success')
  .orderBy('score', 'desc')
  .limit(10)
  .get()
```

**特定ルームの情報取得:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .get()
```

**特定ルームのリアルタイム監視:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .onSnapshot((doc) => {
    // UI更新
  })
```

### 5.2 参加者関連

**参加者一覧取得（参加順）:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .collection('participants')
  .orderBy('joinedAt', 'asc')
  .get()
```

**参加者一覧のリアルタイム監視:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .collection('participants')
  .orderBy('joinedAt', 'asc')
  .onSnapshot((snapshot) => {
    // UI更新
  })
```

### 5.3 投稿関連

**最新の投稿一覧取得:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .collection('submissions')
  .orderBy('createdAt', 'desc')
  .limit(50)
  .get()
```

**採用された投稿のみ取得（しりとりチェーン）:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .collection('submissions')
  .where('validation.isAdopted', '==', true)
  .orderBy('validation.adoptionOrder', 'asc')
  .get()
```

**特定ユーザーの投稿一覧取得:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .collection('submissions')
  .where('userId', '==', userId)
  .orderBy('createdAt', 'desc')
  .get()
```

**投稿一覧のリアルタイム監視:**
```typescript
db.collection('rooms')
  .doc(roomId)
  .collection('submissions')
  .orderBy('createdAt', 'desc')
  .limit(50)
  .onSnapshot((snapshot) => {
    // UI更新
  })
```

---



## 7. セキュリティ考慮事項

### 7.2 データ検証

**ルーム作成時:**
- status は 'waiting' のみ
- failureReason は null
- currentSequence は 0
- chainCount は 0
- usedWords は空配列
- isGoalReached は false
- startedAt は null
- timeLimit は正の整数

**投稿作成時:**
- userId が自分のauth.uidと一致
- status は 'processing' のみ
- aiResult と validation は含まれていない

---
