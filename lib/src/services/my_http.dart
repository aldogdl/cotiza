import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:autoparnet_cotiza/vars/boxes_names.dart';

import '../entity/user_admin.dart';

class MyHttp {

  Map<String, dynamic> result = {'abort': false, 'msg':'ok', 'body':[]};
  String tokenServer = '0';

  ///
  Future<void> getTokenServer() async {
    
    late Box<UserAdmin> boxUser;
    if(!Hive.isBoxOpen(BoxesNames.userAdminBox)) {
      await Hive.openBox<UserAdmin>(BoxesNames.userAdminBox);
      boxUser = Hive.box<UserAdmin>(BoxesNames.userAdminBox);
      tokenServer = boxUser.values.first.tkServer;
    }else{
      boxUser = Hive.box<UserAdmin>(BoxesNames.userAdminBox);
      tokenServer = boxUser.values.first.tkServer;
    }
  }

  ///
  Future<void> getD(String uri, {bool hasToken = true}) async {

    cleanResult();
    Uri url = Uri.parse(uri);
    assert((){
      _imprimirEnConsola(titulo: 'HTTP::getD::', msg: uri);
      return true;
    }());

    Map<String, String> headers = {'Accept': 'application/json'};
    if(hasToken) {
      if(tokenServer == '0') {
        await getTokenServer();
      }
      headers['Authorization'] = 'Bearer $tokenServer';
    }
    
    http.Response reServer = await http.get(url, headers: headers);
    if(reServer.statusCode == 200) {
      var body = json.decode(reServer.body);
      if(body.isNotEmpty) {
        
        try {
          result['body'] = List<Map<String, dynamic>>.from(body);
        } catch (e) {
          result = Map<String, dynamic>.from(body);
          if(result.containsKey('abort')) {
            if(body['abort']) {
              await _analizaErrorFromServerCode200();
            }
          }else{
            debugPrint('### ERROR DESCONOCIDO ###');
            debugPrint('$body');
          }
        }
      }else{
        result['body'] = [];
      }

    }else{
      await _analizaErrorFromServer(reServer);
    }

  }

  ///
  Future<void> postD(String uri, Map<String, dynamic> data, {bool hasToken = true}) async {

    cleanResult();
    Uri url = Uri.parse(uri);

    assert((){
      _imprimirEnConsola(titulo: 'HTTP::postD::', msg: uri);
      return true;
    }());

    late http.Response req;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    if(hasToken) {
      if(tokenServer == '0') {
        await getTokenServer();
      }
      headers['Authorization'] = 'Bearer $tokenServer';
    }

    if(uri.contains('secure')) {
      req = await http.post(url, headers: headers, body: json.encode(data));
    }else{
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields['data'] = json.encode(data);
      req = await http.Response.fromStream(await request.send());
    }

    if(req.statusCode == 200) {
      var body = json.decode(req.body);
      
      if(body.isNotEmpty) {
        try {
          result['body'] = List<Map<String, dynamic>>.from(body);
        } catch (e) {
          result = Map<String, dynamic>.from(body);
          if(result.containsKey('token')) {
            result = {
              'abort' : false, 'msg'   : 'ok', 'body'  : result['token']
            };
          }else{
            if(body['abort']) {
              await _analizaErrorFromServerCode200();
            }
          }
        }
      }

    }else{
      await _analizaErrorFromServer(req);
    }
  }

  ///
  Future<void> upFile(
    String uri, XFile file,
    {required Map<String, dynamic>? metas, bool hasToken = true}
  ) async {

    cleanResult();
    assert((){
      _imprimirEnConsola(titulo: 'HTTP::upFiles::', msg: uri);
      return true;
    }());

    Uri url = Uri.parse(uri);
    var req = http.MultipartRequest('POST', url);
    Map<String, String> headers = {'Accept': 'application/json'};
    if(hasToken) {
      if(tokenServer == '0') {
        await getTokenServer();
      }
      headers['Authorization'] = 'Bearer $tokenServer';
    }

    Uint8List hasFoto = await file.readAsBytes();
    if( hasFoto.isNotEmpty ) {

      req.files.add(
        http.MultipartFile.fromBytes(
          metas!['campo'], hasFoto, filename: metas['filename'],
          contentType: MediaType('image', metas['ext'])
        )
      );

      req.fields['data'] = json.encode({
        'filename':metas['filename'],
        'campo'   :metas['campo'],
        'idOrden' : (metas.containsKey('idOrden')) ? metas['idOrden'] : '0'
      });
      req.headers.addAll(headers);
      http.Response reServer = await http.Response.fromStream(await req.send());

      if(reServer.statusCode == 200) {
        var body = json.decode(reServer.body);
        if(body.isNotEmpty) {
          try {
            result['body'] = List<Map<String, dynamic>>.from(body);
          } catch (e) {
            result = Map<String, dynamic>.from(body);
            if(body['abort']) {
              await _analizaErrorFromServerCode200();
            }
          }
        }

      }else{
        await _analizaErrorFromServer(reServer);
      }
    }else{
      result['abort'] = true;
      result['msg'] = 'err';
      result['body'] = 'Sin Imagenes para enviar.';
    }
  }

  /// 
  Future<void> upFileByData(
    String uri,
    {required Map<String, dynamic> metas}
  ) async {

    cleanResult();
    assert((){
      _imprimirEnConsola(titulo: 'HTTP::upFileByData::', msg: uri);
      return true;
    }());

    Uri url = Uri.parse(uri);
    var req = http.MultipartRequest('POST', url);
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${metas['token']}'
    };

    String filename = metas['filename'];
    List<String> partes = filename.split('.');
    String ext = partes.last;
    String campo = '${DateTime.now().millisecondsSinceEpoch}';

    if( metas['bytes'].isNotEmpty ) {

      req.files.add(
        http.MultipartFile.fromBytes(
          campo,
          List<int>.from(metas['bytes']),
          filename: filename,
          contentType: MediaType('image', ext)
        )
      );
      req.fields['data'] = json.encode({
        'filename': filename,
        'campo'   : campo,
        'idTmp'   : (metas.containsKey('idTmp')) ? metas['idTmp'] : '',
        'idOrden' : (metas.containsKey('idOrden')) ? metas['idOrden'] : ''
      });
      req.headers.addAll(headers);
      http.Response reServer = await http.Response.fromStream(await req.send());

      if(reServer.statusCode == 200) {
        var body = json.decode(reServer.body);
        if(body.isNotEmpty) {
          try {
            result['body'] = List<Map<String, dynamic>>.from(body);
          } catch (e) {
            result = Map<String, dynamic>.from(body);
            if(body['abort']) {
              await _analizaErrorFromServerCode200();
            }
          }
        }
      }else{
        await _analizaErrorFromServer(reServer);
      }

    }else{
      result['abort']= true;
      result['msg']  = 'err';
      result['body'] = 'Sin Imagenes para enviar.';
    }
  }

  ///
  void cleanResult() { result = {'abort': false, 'msg':'ok', 'body':[]}; }

  ///
  Future<void> _analizaErrorFromServer(http.Response reServer) async {

    result['msg'] = 'amor';

    if(reServer.body.toString().contains('Expired ')) {
      
      result['abort'] = true;
      result['msg'] = 'Expired';
      result['body'] = 'refreshToken';
    }else{

      if(reServer.body.toString().contains('Access Denied')){
        result['abort'] = true;
        result['msg'] = 'Acceso Denegado';
        result['body'] = 'No tienes autorización para esta sección.';
      }

      if(reServer.body.toString().contains('Invalid ')){
        result['abort'] = true;
        result['msg'] = 'Invalidas';
        result['body'] = 'Revisa tus datos, las Credenciales son invalidas.';
      }
    }

    if(result['msg'] == 'amor') {
      result['abort'] = true;
      result['msg'] = 'Error';
      result['body'] = 'Error desconocido, contacta al Asesor.';
    }
    var res = json.decode(reServer.body);
    assert((){
      _imprimirEnConsola(titulo: '::ACA EN REVISANDO ERROR::', msg: '$res | -- | ${res['detail']}');
      return true;
    }());

  }

  ///
  Future<void> _analizaErrorFromServerCode200() async {

    _imprimirEnConsola(titulo: '::ACA EN REVISANDO ERROR CODE 200::', msg: json.encode(result));
  }

  ///
  void _imprimirEnConsola({ required String titulo, required var msg }) {
    
    debugPrint(titulo);
    debugPrint(msg);
  }


}