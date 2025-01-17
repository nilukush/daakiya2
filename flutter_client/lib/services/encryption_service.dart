import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EncryptionService {
  late final RSAPublicKey publicKey;
  late final RSAPrivateKey privateKey;

  EncryptionService() {
    _generateKeyPair();
  }

  void _generateKeyPair() {
    final keyPair = RSAKeyGenerator().generateKeyPair();
    publicKey = keyPair.publicKey as RSAPublicKey;
    privateKey = keyPair.privateKey as RSAPrivateKey;
  }

  String encrypt(String text) {
    final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
    final encrypted = encrypter.encrypt(text);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
    final encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted);
  }
}