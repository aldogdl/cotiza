import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../services/pushes_service.dart';
import '../pages/home/data_shared/ds_repo.dart';

final Map<String, dynamic> cotizaciones = {
  'id'   : 'ANETPUSH',
  'name' : 'Notificaciones de Respuestas',
  'sound': 'cotizaciones',
  'descr': 'Recibe respuestas a tus cotizaciones',
};

class FBMGoogle {

  BuildContext? contextCurrent;
  final Globals globals = getSngOf<Globals>();
  final DsRepo dsRepo = getSngOf<DsRepo>();
  
  late FirebaseMessaging? msgAppPush;

  FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  NotificationSettings? settings;
  bool isInitialized = false;
  String? tokenMsg = '';

  ///
  set setContextCurrent(BuildContext cntx) {
    contextCurrent = cntx;
  }

  /// Creamos el canal de notificaciones.
  /// Iniciamos la configuracion de Local Notification.
  /// Iniciamos la instancia de messanging.
  /// Solicitamos los permisos pertinentes.
  Future<void> init() async {

    isInitialized = true;
    if(!kIsWeb) {
      // Entramos solo en la app
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        cotizaciones['id'],
        cotizaciones['name'],
        description: cotizaciones['descr'],
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(cotizaciones['sound']),
        enableVibration: true,
      );

      await fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

      const AndroidInitializationSettings initSetting = AndroidInitializationSettings('app_icon');
      const InitializationSettings config = InitializationSettings(android: initSetting);
      await fln.initialize(config, onSelectNotification: selectNotification);
    }
    
    msgAppPush = FirebaseMessaging.instance;
    await _solicitarPermisos();
    //await dsRepo.openBoxPushes();
    //await dsRepo.openBoxMain();
  }
  
  ///
  void selectNotification(String? payload) async {
    // final pushes = await PushesService.getAll();
  }

  ///
  Future<void> _solicitarPermisos() async {

    settings = await msgAppPush!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  ///
  Future<void> recuperandoTokenPush() async{

    // eqoFZXykQ66l6QEqAu5nqZ:APA91bFwOqYizILkS5kxGzcBkfit_2p3LgryUkCVLkAFcjDsKs3pJjtN6iiesLf6H5aWe3vqhrgvROu92uzxVUJ7aAPoRIxROr_joa1UmFhKuNMCOyh-W_u8Ton9VZ0pa6S9P0ltxZDc
    if(tokenMsg == null || tokenMsg!.isEmpty) {
      tokenMsg = await msgAppPush!.getToken();
    }
  }

  ///
  Future<void> configMsgOn() async {

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) => _showNotification(message)
    );
  }

  ///
  Future<void> _showNotification(RemoteMessage msg) async {

    bool existe = await PushesService.existeId(msg.messageId);
    if(existe){ return; }
    await PushesService.setNewMsg(msg);

    if(!kIsWeb) {

      late final NotificationDetails platformChannelSpecifics;
      // En la app
      platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          cotizaciones['id'],
          cotizaciones['name'],
          channelDescription: cotizaciones['descr'],
          priority: Priority.high,
          importance: Importance.max,
          ticker: 'ticker',
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(cotizaciones['sound']),
        ),
      );

      int? intId = int.tryParse(msg.messageId ?? '1'); 
      await fln.show(
        intId ?? 1,
        msg.data['title'],
        'Ya hay respuestas para una de tus solicitudes de cotización',
        platformChannelSpecifics,
      );
      await FlutterRingtonePlayer.playNotification(
        asAlarm: true,
        volume: 1,
        looping: false
      );
    }

    if(msg.data.containsKey('tipo')) {

      
    }
  }

}