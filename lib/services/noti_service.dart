import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photo_album/main.dart';

class NotiService {
  void fileUploaded(bool success) async {

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final succesUpload = success ? "File succesfully uploaded!" : "File failed to upload!";

    await flutterLocalNotificationsPlugin.show(
      0,
      'File Info!',
      succesUpload,
      notificationDetails,
    );
  }

}