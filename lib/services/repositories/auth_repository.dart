import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/firebase_providers.dart';

/// Firebase匿名認証を扱うリポジトリ
class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  Future<User?>? _signInFuture;

  /// 匿名サインイン（既にログイン済みならそのユーザーを返す）
  Future<User> signInAnonymouslyIfNeeded() async {
    debugPrint('[AuthRepository] signInAnonymouslyIfNeeded: 開始');
    final current = _firebaseAuth.currentUser;
    if (current != null) {
      debugPrint('[AuthRepository] 既にログイン済み: userId=${current.uid}');
      return current;
    }

    debugPrint('[AuthRepository] 匿名認証を開始します');
    debugPrint('[AuthRepository] FirebaseAuth app: ${_firebaseAuth.app.name}');
    debugPrint(
      '[AuthRepository] FirebaseAuth app options: ${_firebaseAuth.app.options.projectId}',
    );

    // 二重実行による内部エラーを避けるため、同一Futureを共有
    _signInFuture ??= _firebaseAuth.signInAnonymously().then((credential) {
      debugPrint('[AuthRepository] 匿名認証成功: userId=${credential.user?.uid}');
      return credential.user;
    }).catchError((Object error) {
      debugPrint('[AuthRepository] signInAnonymously内でエラー: $error');
      debugPrint('[AuthRepository] エラータイプ: ${error.runtimeType}');
      if (error is FirebaseAuthException) {
        debugPrint('[AuthRepository] FirebaseAuthException詳細:');
        debugPrint('[AuthRepository]   code: ${error.code}');
        debugPrint('[AuthRepository]   message: ${error.message}');
        debugPrint('[AuthRepository]   email: ${error.email}');
        debugPrint('[AuthRepository]   credential: ${error.credential}');
        debugPrint('[AuthRepository]   plugin: ${error.plugin}');
        debugPrint('[AuthRepository]   toString: ${error.toString()}');
      }
      throw error;
    });

    try {
      final user = await _signInFuture!;
      if (user == null) {
        debugPrint('[AuthRepository] エラー: ユーザー情報がnull');
        _signInFuture = null;
        throw StateError('匿名認証に失敗しました: ユーザー情報が取得できませんでした');
      }
      debugPrint(
        '[AuthRepository] signInAnonymouslyIfNeeded: 成功 userId=${user.uid}',
      );
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthRepository] FirebaseAuthException: code=${e.code}, message=${e.message}',
      );
      debugPrint('[AuthRepository] FirebaseAuthException詳細:');
      debugPrint('[AuthRepository]   code: ${e.code}');
      debugPrint('[AuthRepository]   message: ${e.message}');
      debugPrint('[AuthRepository]   email: ${e.email}');
      debugPrint('[AuthRepository]   credential: ${e.credential}');
      debugPrint('[AuthRepository]   plugin: ${e.plugin}');
      debugPrint('[AuthRepository]   toString: ${e.toString()}');
      _signInFuture = null;

      // internal-errorの場合、より詳細なメッセージを提供
      String errorMessage;
      if (e.code == 'internal-error') {
        errorMessage = '匿名認証に失敗しました。Firebase Consoleで匿名認証が有効になっているか確認してください。\n'
            'エラー詳細: ${e.message ?? '不明なエラー'}';
        debugPrint('[AuthRepository] ⚠️ internal-errorが発生しました。');
        debugPrint('[AuthRepository] Firebase Consoleで以下を確認してください:');
        debugPrint(
          '[AuthRepository] 1. Authentication > Sign-in method > Anonymous が有効になっているか',
        );
        debugPrint('[AuthRepository] 2. プロジェクトの設定が正しいか');
        debugPrint('[AuthRepository] 3. GoogleService-Info.plistが正しく配置されているか');
      } else {
        errorMessage = '匿名認証に失敗しました: ${e.code} - ${e.message ?? '不明なエラー'}';
      }

      throw StateError(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository] 予期しないエラー: $e');
      debugPrint('[AuthRepository] エラータイプ: ${e.runtimeType}');
      debugPrint('[AuthRepository] スタックトレース: $stackTrace');
      _signInFuture = null;
      throw StateError('匿名認証に失敗しました: $e');
    }
  }

  /// 現在のユーザーID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// 認証状態の監視
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
}

/// AuthRepository プロバイダー
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    final auth = ref.watch(firebaseAuthProvider);
    return AuthRepository(firebaseAuth: auth);
  },
);

/// 認証状態のStream Provider（UI側で再ビルドさせるために利用）
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);
