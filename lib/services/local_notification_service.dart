// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import '../message.dart';
import '../model/notification.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        // var nada = ModelNotification.fromJson(route);
        if (payload != null) {
          // final body = jsonEncode(route);
          // final body2 = jsonDecode(body);
          debugPrint('isinya apa2? $payload');
          // Note note = Note.fromJsonString(payload);
          Sakura sakurai = sakuraFromJson(payload);
          //  Note note = Note.fromJsonString(payload);
          debugPrint('pasrah ${sakurai.notificatioon.body}');
          debugPrint('pasrah ${sakurai.data.route}');
          // final RemoteMessage args = payload as RemoteMessage;
          // ModelNotification note = ModelNotification.fromJson(payload);
          // debugPrint('isinya apa3? ${args.messageId.toString()}');
          await Navigator.pushNamed(
            context,
            '${sakurai.data.route}',
            arguments: MessageArgumentss(sakurai, true),
          );
          // final body = jsonEncode(route);
          // final body2 = jsonDecode(body);
          // debugPrint(
          //   'isinya apa1? ${ModelNotification.fromJson(route).via}',
          // );
          // await Navigator.of(context)
          //     .pushNamed('/message', arguments: MessageArguments(route, true));
        }
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id, channel.name, channel.description,
              importance: Importance.max, priority: Priority.high));
      debugPrint('merepotkan, ${message.sentTime}');

      Sakura newSakura = Sakura(
        messageId: message.messageId,
        senderId: message.senderId,
        category: message.category,
        collapseKey: message.collapseKey,
        contentAvailable: message.contentAvailable,
        data: Data(
          via: message.data['via'],
          count: message.data['count'],
          route: message.data['route'],
        ),
        from: message.from,
        sentTime: message.sentTime,
        threadId: message.threadId,
        ttl: message.ttl,
        notificatioon: Notificatioon(
          title: message.notification?.title,
          body: message.notification?.body,
        ),
      );
      String sakuraJsonString = sakuraToJson(newSakura);
      // Note newNote = Note(
      //     via: message.data['via'],
      //     count: message.data['count'],
      //     route: message.data['route']);
      // String noteJsonString = newNote.toJsonString();
      await _notificationsPlugin.show(
        notification.hashCode,
        notification!.title,
        notification.body,
        notificationDetails,
        payload: sakuraJsonString,
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
