import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;
import 'package:shared_preferences/shared_preferences.dart';

class PushesService {

  static const String nomBox = 'pushes';
  static SharedPreferences? _prefs;
  static List<Map<String, dynamic>> _pushes = [];
  static Map<String, dynamic> push = {
    'id':'', 'tipo':'', 'id_orden':'', 'msg': ''
  };

  ///
  static Future<void> instanciar() async {
    _prefs = await SharedPreferences.getInstance();
    if(_prefs != null) {
      _getContent();
    }
  }

  ///
  static void _getContent() {

    if(_prefs != null) {
      if(_pushes.isEmpty) {
        final String? pushesBox = _prefs!.getString(nomBox);
        if(pushesBox != null) {
          _pushes = List<Map<String, dynamic>>.from(json.decode(pushesBox));
        }
      }
    }
  }

  ///
  static Future<List<Map<String, dynamic>>> getAll() async {

    _prefs = await SharedPreferences.getInstance();
    _getContent();
    if(_pushes.isNotEmpty) {
      return _pushes;
    }
    return [];
  }

  ///
  static Future<bool> existeId(String? messageId) async {
    _prefs = await SharedPreferences.getInstance();
    _getContent();
    if(_pushes.isNotEmpty) {
      int ind = _pushes.indexWhere((element) => element['id'] == messageId);
      return (ind != -1) ? true : false;
    }
    return false;
  }

  ///
  static Future<void> setNewMsg(RemoteMessage msg) async {

    var p = Map<String, dynamic>.from(push);
    p['id']  = msg.messageId;
    p['tipo']= msg.data['tipo'];
    p['id_orden']= msg.data['id_orden'];
    p['msg']= msg.notification!.body;
    _pushes.add(p);
    _prefs = await SharedPreferences.getInstance();
    if(_prefs != null) {
      await _prefs!.setString(nomBox, json.encode(_pushes));
    }
  }
}