class Message {
  final String id;
  final String address;
  final String body;
  final int date;
  final int type;
  final String userId;

  Message({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.type,
    required this.userId,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      address: map['address'] as String,
      body: map['body'] as String,
      date: map['date'] as int,
      type: map['type'] as int,
      userId: map['userId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'body': body,
      'date': date,
      'type': type,
      'userId': userId,
    };
  }

  Message copyWithEncryptedBody(String encryptedBody) {
    return Message(
      id: id,
      address: address,
      body: encryptedBody,
      date: date,
      type: type,
      userId: userId,
    );
  }
}