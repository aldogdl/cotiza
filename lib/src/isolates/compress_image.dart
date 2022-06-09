
import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:autoparnet_cotiza/src/services/get_uris.dart';
import 'package:autoparnet_cotiza/src/services/my_http.dart';

final MyHttp http = MyHttp();
late List<Uint8List> fotos;

///
Future<void> getMetasFromPath(SendPort p) async {

  final r = ReceivePort();
  p.send(r.sendPort);
  Map<String, dynamic> metas = {};

  await for (String msg in r) {

    if(msg == 'fin') { break; }
    if(msg == 'clean') {

      metas = {};

    }else{

      metas = json.decode(msg);
      if(metas.containsKey('sended')) {

        metas = await sendFotoToServer(metas);
        
      }else{

        File file = File(metas['path']);
        Uint8List list = file.readAsBytesSync();
        img.Image image = img.decodeImage(list)!;
        metas['isHorizontal'] = image.width > image.height;
        metas['bytes'] = list;
      }
    }

    p.send(metas);
  }
  Isolate.exit();
}

///
Future<Map<String, dynamic>> sendFotoToServer(Map<String, dynamic> params) async {

  String uri = GetUris.getUriBy('upload_img');
  await http.upFileByData(uri, metas: params);

  if(!http.result['abort']) {
    params['sended']  = true;
    params.remove('bytes');
    params.remove('token');
  }else{
    params['hasErr'] = true;
    params['motivo'] = http.result['body'];
  }

  return params;
}
