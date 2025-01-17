import 'package:flutter_test/flutter_test.dart';
import 'package:sms_sync_client/services/encryption_service.dart';

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionService();
  });

  test('encrypt and decrypt text successfully', () {
    const originalText = 'Hello, World!';
    final encrypted = encryptionService.encrypt(originalText);
    final decrypted = encryptionService.decrypt(encrypted);
    expect(decrypted, equals(originalText));
  });

  test('encrypted text is different from original', () {
    const originalText = 'Hello, World!';
    final encrypted = encryptionService.encrypt(originalText);
    expect(encrypted, isNot(equals(originalText)));
  });
}