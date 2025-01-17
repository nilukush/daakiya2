import '../models/message.dart';

class MessageAnalytics {
  final int totalMessages;
  final Map<String, int> messagesByContact;
  final Map<String, int> messagesByType;
  final double averageMessagesPerDay;
  final Map<String, int> messagesByMonth;

  MessageAnalytics({
    required this.totalMessages,
    required this.messagesByContact,
    required this.messagesByType,
    required this.averageMessagesPerDay,
    required this.messagesByMonth,
  });
}

class AnalyticsService {
  MessageAnalytics analyzeMessages(List<Message> messages) {
    final messagesByContact = <String, int>{};
    final messagesByType = <String, int>{};
    final messagesByMonth = <String, int>{};

    for (final message in messages) {
      // Count by contact
      messagesByContact.update(
        message.address,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      // Count by type
      final type = MessageType.values[message.type].displayName;
      messagesByType.update(
        type,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      // Count by month
      final date = DateTime.fromMillisecondsSinceEpoch(message.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      messagesByMonth.update(
        monthKey,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Calculate average messages per day
    if (messages.isEmpty) return MessageAnalytics(
      totalMessages: 0,
      messagesByContact: {},
      messagesByType: {},
      averageMessagesPerDay: 0,
      messagesByMonth: {},
    );

    final firstMessage = DateTime.fromMillisecondsSinceEpoch(
      messages.map((m) => m.date).reduce((min, date) => date < min ? date : min)
    );
    final lastMessage = DateTime.fromMillisecondsSinceEpoch(
      messages.map((m) => m.date).reduce((max, date) => date > max ? date : max)
    );
    final daysDifference = lastMessage.difference(firstMessage).inDays + 1;
    final averageMessagesPerDay = messages.length / daysDifference;

    return MessageAnalytics(
      totalMessages: messages.length,
      messagesByContact: messagesByContact,
      messagesByType: messagesByType,
      averageMessagesPerDay: averageMessagesPerDay,
      messagesByMonth: messagesByMonth,
    );
  }
}