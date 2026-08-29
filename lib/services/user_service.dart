import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Obtém o usuário ou cria o perfil se não existir (lazy creation)
  Future<UserModel> getUserOrCreate({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) async {
    final docRef = _users.doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }

    // Criar perfil novo
    final user = UserModel(
      uid: uid,
      name: name,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(user.toMap());
    return user;
  }

  Future<void> createUserProfile(
    String uid,
    String name,
    String phone,
    String email,
  ) async {
    final user = UserModel(
      uid: uid,
      name: name,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _users.doc(uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUser(String uid, {String? name, String? phone}) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) data['name'] = name.trim();
    if (phone != null) data['phone'] = phone;
    await _users.doc(uid).update(data);
  }

  Stream<UserModel> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Usuário não encontrado');
      }
      return UserModel.fromMap(doc.data()!);
    });
  }

  /// Stream que cria o perfil automaticamente se não existir
  Stream<UserModel> watchUserOrCreate({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) {
    return _users.doc(uid).snapshots().asyncMap((doc) async {
      if (!doc.exists) {
        // Criar perfil automaticamente
        final user = UserModel(
          uid: uid,
          name: name,
          phone: phone,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await doc.reference.set(user.toMap());
        return user;
      }
      return UserModel.fromMap(doc.data()!);
    });
  }

  String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Sem permissão para acessar os dados';
      case 'not-found':
        return 'Documento não encontrado';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente';
      default:
        return 'Erro ao acessar dados: ${e.message ?? e.code}';
    }
  }
}