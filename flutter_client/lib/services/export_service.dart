import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';

class ExportService {
  Future<String> exportToJson(List<Message> messages) async {
    final json = jsonEncode(messages.map((m) => m.toMap()).toList());
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/messages_export.json');
    await file.writeAsString(json);
    return file.path;
  }

  Future<String> exportToCsv(List<Message> messages) async {
    final csv = StringBuffer();
    csv.writeln('ID,Address,Body,Date,Type');
    
    for (final message in messages) {
      final date = DateTime.fromMillisecondsSinceEpoch(message.date).toIso8601String();
      csv.writeln('${message.id},${message.address},"${message.body}",$date,${message.type}');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/messages_export.csv');
    await file.writeAsString(csv.toString());
    return file.path;
  }
}