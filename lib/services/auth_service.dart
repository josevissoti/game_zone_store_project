import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Atualizar displayName no Firebase Auth
    if (credential.user != null) {
      await credential.user!.updateDisplayName(name.trim());
      await credential.user!.reload();
    }

    // Criar perfil no Firestore com retry (race condition do token)
    if (credential.user != null) {
      await _createUserProfileWithRetry(
        uid: credential.user!.uid,
        name: name.trim(),
        phone: phone,
        email: email.trim().toLowerCase(),
      );
    }

    return credential;
  }

  Future<void> _createUserProfileWithRetry({
    required String uid,
    required String name,
    required String phone,
    required String email,
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        await _userService.createUserProfile(uid, name, phone, email);
        return; // Sucesso
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied' && i < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (i + 1))); // 500ms, 1s, 1.5s
          await _auth.currentUser?.reload(); // Atualiza token
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'user-disabled':
        return 'Conta desativada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'email-already-in-use':
        return 'E-mail já está em uso';
      case 'weak-password':
        return 'Senha muito fraca (mín. 6 caracteres)';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet';
      default:
        return 'Erro ao autenticar: ${e.message ?? e.code}';
    }
  }
}