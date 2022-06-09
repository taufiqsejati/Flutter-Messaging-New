// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import '../message.dart';
import '../model/helper.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          RemoteMessage args = remoteMessageFromJson(payload);
          await Navigator.pushNamed(
            context,
            '${args.data["route"]}',
            arguments: MessageArguments(args, true),
          );
        }
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
          importance: Importance.max,
          priority: Priority.high,
          // icon: 'launch_background',
        ),
      );
      String testingJsonString = remoteMessageToJson(message);
      if (notification != null && android != null) {
        await _notificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          notificationDetails,
          payload: testingJsonString,
        );
      }
    } on Exception catch (e) {
      print(e);
    }
  }
}
