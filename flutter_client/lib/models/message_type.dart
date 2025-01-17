enum MessageType {
  all,
  inbox,
  sent,
  draft,
  outbox;

  String get displayName {
    switch (this) {
      case MessageType.all: return 'All';
      case MessageType.inbox: return 'Inbox';
      case MessageType.sent: return 'Sent';
      case MessageType.draft: return 'Draft';
      case MessageType.outbox: return 'Outbox';
    }
  }
}