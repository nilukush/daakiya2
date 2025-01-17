import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import 'message_service_provider.dart';

final messagesProvider = StreamProvider<List<Message>>((ref) {
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getMessages();
});