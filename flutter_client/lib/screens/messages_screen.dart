import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filtered_messages_provider.dart';
import '../providers/grouped_messages_provider.dart';
import '../providers/search_provider.dart';
import '../services/analytics_service.dart';
import '../services/export_service.dart';
import '../models/message_type.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedMessages = ref.watch(groupedMessagesProvider);
    final groupBy = ref.watch(groupByProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalytics(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Export JSON'),
                onTap: () => _exportMessages(context, ref, format: 'json'),
              ),
              PopupMenuItem(
                child: const Text('Export CSV'),
                onTap: () => _exportMessages(context, ref, format: 'csv'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(ref),
          _buildGroupingControls(ref),
          Expanded(
            child: groupedMessages.isEmpty
                ? const Center(child: Text('No messages found'))
                : _buildGroupedList(groupedMessages),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
        decoration: const InputDecoration(
          hintText: 'Search messages...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGroupingControls(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SegmentedButton<GroupBy>(
        segments: const [
          ButtonSegment(value: GroupBy.date, label: Text('Date')),
          ButtonSegment(value: GroupBy.contact, label: Text('Contact')),
          ButtonSegment(value: GroupBy.type, label: Text('Type')),
        ],
        selected: {ref.watch(groupByProvider)},
        onSelectionChanged: (Set<GroupBy> selection) {
          ref.read(groupByProvider.notifier).state = selection.first;
        },
      ),
    );
  }

  Widget _buildGroupedList(Map<String, List<Message>> groupedMessages) {
    return ListView.builder(
      itemCount: groupedMessages.length,
      itemBuilder: (context, index) {
        final group = groupedMessages.entries.elementAt(index);
        return ExpansionTile(
          title: Text(group.key),
          children: group.value.map((message) => MessageTile(message: message)).toList(),
        );
      },
    );
  }

  Future<void> _showAnalytics(BuildContext context, WidgetRef ref) async {
    final messages = ref.read(filteredMessagesProvider);
    final analytics = AnalyticsService().analyzeMessages(messages);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Analytics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Messages: ${analytics.totalMessages}'),
              Text('Average Messages/Day: ${analytics.averageMessagesPerDay.toStringAsFixed(1)}'),
              const Divider(),
              const Text('Messages by Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...analytics.messagesByContact.entries.map(
                (e) => Text('${e.key}: ${e.value}')
              ),
              const Divider(),
              const Text('Messages by Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...analytics.messagesByType.entries.map(
                (e) => Text('${e.key}: ${e.value}')
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportMessages(BuildContext context, WidgetRef ref, {required String format}) async {
    final messages = ref.read(filteredMessagesProvider);
    final exportService = ExportService();
    
    try {
      final path = format == 'json'
          ? await exportService.exportToJson(messages)
          : await exportService.exportToCsv(messages);
          
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Messages exported to: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class FilterDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(searchFilterProvider);

    return AlertDialog(
      title: const Text('Filter Messages'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Date Range'),
            onTap: () async {
              final dateRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (dateRange != null) {
                ref.read(searchFilterProvider.notifier).state = MessageFilter(
                  startDate: dateRange.start,
                  endDate: dateRange.end,
                  messageType: currentFilter.messageType,
                  contact: currentFilter.contact,
                );
              }
            },
          ),
          DropdownButtonFormField<MessageType>(
            value: currentFilter.messageType,
            items: MessageType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(searchFilterProvider.notifier).state = MessageFilter(
                  startDate: currentFilter.startDate,
                  endDate: currentFilter.endDate,
                  messageType: value,
                  contact: currentFilter.contact,
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(searchFilterProvider.notifier).state = const MessageFilter();
            Navigator.pop(context);
          },
          child: const Text('Clear Filters'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}