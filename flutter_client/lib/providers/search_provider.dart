import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_type.dart';
import '../models/message.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchFilterProvider = StateProvider<MessageFilter>((ref) => const MessageFilter());

class MessageFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? contact;
  final MessageType messageType;
  final bool? isEncrypted;

  const MessageFilter({
    this.startDate,
    this.endDate,
    this.contact,
    this.messageType = MessageType.all,
    this.isEncrypted,
  });

  bool matches(Message message) {
    if (startDate != null && message.date < startDate!.millisecondsSinceEpoch) {
      return false;
    }
    if (endDate != null && message.date > endDate!.millisecondsSinceEpoch) {
      return false;
    }
    if (contact != null && !message.address.toLowerCase().contains(contact!.toLowerCase())) {
      return false;
    }
    if (messageType != MessageType.all && message.type != messageType.index) {
      return false;
    }
    return true;
  }
}