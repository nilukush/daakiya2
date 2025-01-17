import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import 'encryption_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EncryptionService _encryptionService = EncryptionService();

  Future<void> saveMessage(Message message) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final encryptedBody = _encryptionService.encrypt(message.body);
    final encryptedMessage = message.copyWithEncryptedBody(encryptedBody);

    await _firestore
        .collection('messages')
        .doc(message.id)
        .set(encryptedMessage.toMap());
  }

  Stream<List<Message>> getMessages() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('messages')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final message = Message.fromMap(doc.data());
              final decryptedBody = _encryptionService.decrypt(message.body);
              return message.copyWithEncryptedBody(decryptedBody);
            }).toList());
  }
}