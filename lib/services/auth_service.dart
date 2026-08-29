import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    // Perfil será criado lazy no primeiro acesso (UserService.getUserOrCreate)
    // Armazenar dados temporários para uso posterior se necessário
    return credential;
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