import 'package:flutter/material.dart';
import 'package:flutter_application_1/handle_request.dart';

class NotificationScreen extends StatefulWidget {
  final dynamic users;
  const NotificationScreen(this.users, {super.key});

  @override
  State<StatefulWidget> createState() => _NotificationScreen();
}

class _NotificationScreen extends State<NotificationScreen> {
  dynamic announcements = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = {};
      response = await requestHandler.handleRequest(
        context,
        'users/get-all-notifications',
        body: {'id': widget.users['id'], 'category': "Dropping"},
      );
      if (response['success'] == true) {
        setState(() {
          announcements = response['notifications'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Loading announcement error'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
        title: const Text("Notifications"),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ListTile(
              leading: const Icon(Icons.announcement, color: Colors.blue),
              title: Text(announcement['title']),
              subtitle: Text(announcement['description']),
              trailing: Text(
                'Created: ${announcement['createdAt']}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
