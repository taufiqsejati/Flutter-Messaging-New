// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_example/services/local_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message.dart';
import 'message_list.dart';
import 'permissions.dart';
import 'token_monitor.dart';
import 'firebase_options.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(MessagingExampleApp());
}

/// Entry point for the example application.
class MessagingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Example App',
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => Application(),
        '/message': (context) => MessageView(),
      },
    );
  }
}

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token) {
  _messageCount++;
  return jsonEncode({
    'registration_ids': [
      token,
      'da07LmIFTry9I0IzZ4pZLF:APA91bHr8K_dwgGH50jD5upvUntodKCm_N2JwQKyttH7ktV3rHNesI4yoQDMS5kfw-Q5PhOINWqQWpw7AKDdLre0U5NH3aY_EBm7Hn36axkHNmOXJ4I6Wfe7CKi8vr3opUeD-UUTF5DX'
    ],
    // 'to': 'fcm_test',
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
      'route': '/message'
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

/// Renders the example application.
class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  String? _token;

  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize(context);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        Navigator.pushNamed(
          context,
          message.data['route'],
          arguments: MessageArguments(message, true),
        );
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);
      }
      LocalNotificationService.display(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.pushNamed(
        context,
        message.data['route'],
        arguments: MessageArguments(message, true),
      );
    });
  }

  Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Authorization':
              'key=AAAApSAP048:APA91bFzPJsc_aQaJzju7weOZPxYhkKopN3d4yWnWkQ1tBT07L4S7ROOFhrEq2hR4J-EWe_KhsOYyTvKwFhZ7ndSQivXeFzrtFPJHcSUCeRp4x0eSG17p5H0VYc4TlHZHUOlUAz1zbaX',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe Anto':
        {
          print(
            'FlutterFire Messaging Example: Subscribing to topic "anto".',
          );
          await FirebaseMessaging.instance.subscribeToTopic('anto');
          print(
            'FlutterFire Messaging Example: Subscribing to topic "anto" successful.',
          );
        }
        break;
      case 'unsubscribe Anto':
        {
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "anto".',
          );
          await FirebaseMessaging.instance.unsubscribeFromTopic('anto');
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "anto" successful.',
          );
        }
        break;
      case 'subscribe Budi':
        {
          print(
            'FlutterFire Messaging Example: Subscribing to topic "budi".',
          );
          await FirebaseMessaging.instance.subscribeToTopic('budi');
          print(
            'FlutterFire Messaging Example: Subscribing to topic "budi" successful.',
          );
        }
        break;
      case 'unsubscribe Budi':
        {
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "budi".',
          );
          await FirebaseMessaging.instance.unsubscribeFromTopic('budi');
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "budi" successful.',
          );
        }
        break;
      case 'subscribe Public':
        {
          print(
            'FlutterFire Messaging Example: Subscribing to topic "public".',
          );
          await FirebaseMessaging.instance.subscribeToTopic('public');
          print(
            'FlutterFire Messaging Example: Subscribing to topic "public" successful.',
          );
        }
        break;
      case 'unsubscribe Public':
        {
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "public".',
          );
          await FirebaseMessaging.instance.unsubscribeFromTopic('public');
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "public" successful.',
          );
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            print('FlutterFire Messaging Example: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            print('FlutterFire Messaging Example: Got APNs token: $token');
          } else {
            print(
              'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.',
            );
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Messaging'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: onActionSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'subscribe Public',
                  child: Text('Subscribe to Public'),
                ),
                const PopupMenuItem(
                  value: 'unsubscribe Public',
                  child: Text('Unsubscribe to Public'),
                ),
                const PopupMenuItem(
                  value: 'subscribe Budi',
                  child: Text('Subscribe to Budi'),
                ),
                const PopupMenuItem(
                  value: 'unsubscribe Budi',
                  child: Text('Unsubscribe to Budi'),
                ),
                const PopupMenuItem(
                  value: 'subscribe Anto',
                  child: Text('Subscribe to Anto'),
                ),
                const PopupMenuItem(
                  value: 'unsubscribe Anto',
                  child: Text('Unsubscribe to Anto'),
                ),
                // const PopupMenuItem(
                //   value: 'get_apns_token',
                //   child: Text('Get APNs token (Apple only)'),
                // ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: sendPushMessage,
          backgroundColor: Colors.white,
          child: const Icon(Icons.send),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MetaCard('Permissions', Permissions()),
            MetaCard(
              'FCM Token',
              TokenMonitor((token) {
                _token = token;
                return token == null
                    ? const CircularProgressIndicator()
                    : Text(token, style: const TextStyle(fontSize: 12));
              }),
            ),
            MetaCard('Message Stream', MessageList()),
          ],
        ),
      ),
    );
  }
}

/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(_title, style: const TextStyle(fontSize: 18)),
              ),
              _children,
            ],
          ),
        ),
      ),
    );
  }
}
