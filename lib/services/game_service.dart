import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/game/game.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _games =>
      _firestore.collection('games');

  Future<void> createGame(GameModel game) async {
    final docRef = _games.doc();
    final gameWithId = game.copyWith(id: docRef.id);
    await docRef.set(gameWithId.toMap());
  }

  Future<void> updateGame(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _games.doc(id).update(data);
  }

  Future<void> deleteGame(String id) async {
    await _games.doc(id).delete();
  }

  Stream<List<GameModel>> watchGamesByUser(String uid) {
    return _games
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GameModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<GameModel>> getAllGames() async {
    final snapshot = await _games
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) {
      return GameModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<GameModel>> watchAllGames() {
    return _games
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GameModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Sem permissão para realizar esta ação';
      case 'not-found':
        return 'Jogo não encontrado';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente';
      case 'already-exists':
        return 'Jogo já existe';
      default:
        return 'Erro ao acessar dados: ${e.message ?? e.code}';
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;
}