import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../models/message.dart';
import 'filtered_messages_provider.dart';

enum GroupBy {
  date,
  contact,
  type
}

final groupByProvider = StateProvider<GroupBy>((ref) => GroupBy.date);

final groupedMessagesProvider = Provider<Map<String, List<Message>>>((ref) {
  final messages = ref.watch(filteredMessagesProvider);
  final groupBy = ref.watch(groupByProvider);

  switch (groupBy) {
    case GroupBy.date:
      return groupByDate(messages);
    case GroupBy.contact:
      return groupByContact(messages);
    case GroupBy.type:
      return groupByType(messages);
  }
});

Map<String, List<Message>> groupByDate(List<Message> messages) {
  return groupBy(messages, (Message message) {
    final date = DateTime.fromMillisecondsSinceEpoch(message.date);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  });
}

Map<String, List<Message>> groupByContact(List<Message> messages) {
  return groupBy(messages, (Message message) => message.address);
}

Map<String, List<Message>> groupByType(List<Message> messages) {
  return groupBy(messages, (Message message) => MessageType.values[message.type].displayName);
}