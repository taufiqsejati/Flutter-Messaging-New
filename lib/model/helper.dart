import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

RemoteMessage remoteMessageFromJson(String str) =>
    RemoteMessage.fromMap(json.decode(str));

String remoteMessageToJson(RemoteMessage data) => json.encode(data.toMap());
