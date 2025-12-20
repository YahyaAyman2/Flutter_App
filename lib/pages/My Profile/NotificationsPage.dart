import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Color primary = Color(0xFF276152);
  final Color accent = Color(0xFF276152);

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    notifications = [
      {
        "id": "notif_1",
        "title": "Tour Booked Successfully",
        "subtitle": "Your house tour has been confirmed!",
        "time": "1h ago",
        "category": "today",
      },
      {
        "id": "notif_2",
        "title": "Exclusive Offers Inside",
        "subtitle": "Check out new rental offers near you.",
        "time": "1h ago",
        "category": "today",
      },
      {
        "id": "notif_3",
        "title": "Property Review Request",
        "subtitle": "Please leave a review for your recent visit.",
        "time": "2h ago",
        "category": "today",
      },
      {
        "id": "notif_4",
        "title": "Tour Request Accepted",
        "subtitle": "The owner approved your tour request.",
        "time": "1d ago",
        "category": "yesterday",
      },
      {
        "id": "notif_5",
        "title": "New Payment Added",
        "subtitle": "Your new payment method is saved.",
        "time": "1d ago",
        "category": "yesterday",
      },
    ];
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification["id"] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> todayNotifications =
        notifications.where((n) => n["category"] == "today").toList();
    List<Map<String, dynamic>> yesterdayNotifications =
        notifications.where((n) => n["category"] == "yesterday").toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text("Notifications"),
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                if (todayNotifications.isNotEmpty) ...[
                  ...todayNotifications.map((notification) {
                    return _buildNotification(
                      notification["id"]!,
                      notification["title"]!,
                      notification["subtitle"]!,
                      notification["time"]!,
                      primary,
                    );
                  }).toList(),
                ],
                if (yesterdayNotifications.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Text("Yesterday", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 10),
                  ...yesterdayNotifications.map((notification) {
                    return _buildNotification(
                      notification["id"]!,
                      notification["title"]!,
                      notification["subtitle"]!,
                      notification["time"]!,
                      accent,
                    );
                  }).toList(),
                ],
              ],
            ),
    );
  }

  Widget _buildNotification(
    String id,
    String title,
    String subtitle,
    String time,
    Color iconColor,
  ) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(id);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(Icons.notifications, color: iconColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Text(time, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}