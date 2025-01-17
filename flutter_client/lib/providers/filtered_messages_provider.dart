import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import 'messages_provider.dart';
import 'search_provider.dart';

final filteredMessagesProvider = Provider<List<Message>>((ref) {
  final messages = ref.watch(messagesProvider).value ?? [];
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(searchFilterProvider);

  return messages.where((message) {
    if (!filter.matches(message)) {
      return false;
    }
    if (searchQuery.isEmpty) {
      return true;
    }
    return message.body.toLowerCase().contains(searchQuery) ||
           message.address.toLowerCase().contains(searchQuery);
  }).toList();
});