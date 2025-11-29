# Scripts

このディレクトリには、Firestoreの管理・メンテナンス用のスクリプトが含まれています。

## resetRoom.ts

指定されたroomをリセットするスクリプトです。

### 実行するリセット操作

- `participants`サブコレクションの全ドキュメントを削除
- `submissions`サブコレクションの全ドキュメントを削除
- roomドキュメントを初期状態にリセット:
  - `chainCount`: 0
  - `currentCharacter`: "ら"
  - `currentSequence`: 0
  - `goalReachedBy`: ""
  - `isGoalReached`: false
  - `readyCount`: 0
  - `score`: 0
  - `status`: "waiting"
  - `totalParticipants`: 0
  - `totalSubmissions`: 0
  - `usedWords`: []

### 使用方法

```bash
cd functions
npm run reset-room
```

### 注意事項

- このスクリプトを実行する前に、Firebase Admin SDKの認証情報が正しく設定されていることを確認してください
- デフォルトでは`L7qqB8lctYU9niXqOKOT`のroomをリセットします
- 別のroomをリセットする場合は、スクリプト内の`ROOM_ID`定数を変更してください
- **この操作は取り消せません**。実行前に対象のroomが正しいことを確認してください

## listRooms.ts

全てのroomを一覧表示するスクリプトです。

### 使用方法

```bash
cd functions
npm run list-rooms
```

## listCollections.ts

Firestoreの全てのコレクションを一覧表示するスクリプトです。

### 使用方法

```bash
cd functions
npm run list-collections
```

## 認証情報の設定

Firebase Admin SDKを使用するため、以下のいずれかの方法で認証情報を設定する必要があります:

1. **gcloud CLIでログインしている場合:**
   ```bash
   gcloud auth application-default login
   gcloud config set project myakurakumaker
   ```

2. **サービスアカウントキーを使用する場合:**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
   npm run reset-room
   ```

3. **Firebase CLIでログインしている場合:**
   ```bash
   firebase login
   npm run reset-room
   ```
