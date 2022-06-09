import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier,
defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart' show Widget, Text, TextAlign;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../isolates/compress_image.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

class PickerPictures {

  final ImagePicker picker = ImagePicker();
  final Globals globals = getSngOf<Globals>();
  final int maxFotos = 8;
  final int minSize = 720;

  int maxPermitidas = 8;
  // La lista de fotos originales.
  // Esta es llenada cuando apenas son seleccionadas las fotos desde la camara o galeria
  List<XFile> imageFileList = [];
  // La lista de fotos en proceso de subida.
  // Esta es llenada en el momento que una foto ya se envio al servidor
  List<Map<String, dynamic>> imageFileListProcess = [];
  // La lista de fotos listas y subidas.
  // Esta es llenada imediatamente sustituyendo el contenido de imageFileList
  List<Map<String, dynamic>> imageFileListOks = [];
  // La lista de fotos traidas desde el celular a la web.
  List<String> imageWebList = [];

  dynamic pickImageError;
  // Usado para refrescar la app mobil
  ValueNotifier<String> refreshPage = ValueNotifier<String>('none');
  // Utilizado para refrescar la zona de arrastre en la web
  ValueNotifier<int> totalFotosSelected = ValueNotifier(0);
  // idOrden y IdpiezaTmp para cuando comparto fotos desde el mobil, solo para la web
  int idOrden = 0;
  String idPiezaTmp  = '0';
  // Token Server
  String tokenServer = '0';
  // Si fotosFromServer no es bacio, es que se quiere editar una pieza
  List<String> fotosFromServer = [];
  List<String> fotosFromServerDel = [];
  // Mesaje usado fuera de esta clase para avisar lo que esta pasando
  ValueNotifier<Map<String, dynamic>> msgExport = ValueNotifier({'msg':'Iniciando...'});

  bool isInit = true;
  XFile? pictureTmp;
  bool hasPickInBandeja = false;
  // Para la seccion de la camara
  ValueNotifier<int> takePictureTmp  = ValueNotifier(-1);
  ValueNotifier<bool> takePictureOks = ValueNotifier(false);

  ///
  void cleanImgs() {

    fotosFromServer = [];
    fotosFromServerDel = [];
    imageFileList.clear();
    imageFileListOks.clear();
    imageFileListProcess.clear();
    totalFotosSelected.value = 0;
  }

  ///
  Future<void> disposeConfigCamera() async {
    try {
      takePictureTmp.dispose();
      takePictureOks.dispose();
    } catch (_) {}
    imageFileList.clear();
  }

  ///
  Future<void> eliminarFotoTmp() async {

    HapticFeedback.vibrate();
    HapticFeedback.heavyImpact();
    if(File(pictureTmp!.path).existsSync()){
      File(pictureTmp!.path).deleteSync();
    }
    hasPickInBandeja = false;
    pictureTmp = null;
    takePictureTmp.value = -1;
  }

  ///
  Future<void> action(String src) async {
    
    ImageSource source = ImageSource.gallery;
    if(!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if(src == 'camera') {
        source = ImageSource.camera;
      }
    }
    await showSource(source);
  }

  ///
  Future<void> showSource(ImageSource source) async {

    if(source == ImageSource.camera) {
      // con la CAMARA
      try {
        final pickedFileList = await picker.pickImage(source: source, maxWidth: 1024);
        if(pickedFileList != null) {
          _addFotosToList(pickedFileList);
        }
      } catch (e) {
        pickImageError = e;
      }
      
    }else{

      try {

        final pickedFileList = await picker.pickMultiImage(maxWidth: 1024);
        if(pickedFileList != null) {
          for (var i = 0; i < pickedFileList.length; i++) {
            _addFotosToList(pickedFileList[i]);
          }
        }
      } catch (e) {
        pickImageError = e;
      }
    }

  }

  ///
  String determinarNombreFoto(int indexFn, {String prefix = ''}) {

    final String sep = (kIsWeb) ? '/' : Platform.pathSeparator;
    
    List<String> partes = (kIsWeb) ? imageFileList[indexFn].name.split(sep) : imageFileList[indexFn].path.split(sep);
    List<String> ext = partes.last.split('.');

    String foto = '';
    for (var i = 0; i < maxFotos; i++) {
      
      int existeName = -1;
      foto = '$prefix$idOrden-$idPiezaTmp-${i+1}';

      if(fotosFromServerDel.isNotEmpty) {
        existeName = fotosFromServerDel.indexWhere(
          (element) => element.contains(foto)
        );
        if(existeName != -1) {
          fotosFromServerDel.removeAt(existeName);
          break;
        }
      }

      if(fotosFromServer.isNotEmpty) {

        if(existeName == -1) {
          existeName = fotosFromServer.indexWhere(
            (element) => element.contains(foto)
          );
          if(existeName != -1) {
            continue;
          }
        }
      }

      if(existeName == -1) {
        existeName = imageFileListOks.indexWhere(
          (element) => element['filename'].contains(foto)
        );
        if(existeName == -1) {
          break;
        }
      }
    }

    return '$foto.${ext.last}';
  }

  ///
  Future<void> buildLstDeFotosOk({String prefix = ''}) async {


    String idTmp = idPiezaTmp;
    if(idTmp.isEmpty){ return; }

    imageFileListOks = [];
    if(imageFileList.isNotEmpty) {

      for (var i = 0; i < imageFileList.length; i++) {
        
        String fotoName = determinarNombreFoto(i, prefix: prefix);

        int existeName = imageFileListOks.indexWhere(
          (element) => element['filename'] == fotoName
        );

        if(existeName == -1) {
          imageFileListOks.add({
            'filename': fotoName,
            'sended'  : false,
            'hasErr'  : '',
            'from'    : 'xfile',
            'idTmp'   : idTmp,
            'path'    : imageFileList[i].path
          });
        }else{
          imageFileListOks[existeName]['sended'] = false;
          imageFileListOks[existeName]['hasErr'] = '';
        }
      }
    }
    
    // Insertamos como enviadas a las fotos que estan en la lista de fotosFromServer
    if(fotosFromServer.isNotEmpty) {
      for (var i = 0; i < fotosFromServer.length; i++) {

        imageFileListOks.add({
          'filename': fotosFromServer[i],
          'sended'  : true,
          'from'    : 'server',
          'idTmp'   : idTmp
        });
      }
    }
  }

  ///
  Future<void> comprimirImagen({String prefix = ''}) async {

    if(imageFileList.isEmpty){ return; }
    List<XFile> copiaLst = List<XFile>.from(imageFileList);

    await buildLstDeFotosOk(prefix: prefix);
    
    if(!kIsWeb) {
      // Solo para celulares.
      imageFileListProcess.clear();
      await for (final fotoToSend in _prepareFotosAndSend(copiaLst)) {

        imageFileListProcess.add(fotoToSend);
        imageFileListOks[fotoToSend['indexPza']]['sended'] = fotoToSend['sended'];
        if(fotoToSend.containsKey('motivo')) {
          imageFileListOks[fotoToSend['indexPza']]['hasErr'] = fotoToSend['motivo'];
        }
      }
    }
  }

  ///
  Stream<Map<String, dynamic>> _prepareFotosAndSend(List<XFile> fotos) async* {

    String idTmp = idPiezaTmp;

    final p = ReceivePort();
    await Isolate.spawn(getMetasFromPath, p.sendPort);
    final respuestas = StreamQueue<dynamic>(p);
    SendPort sendPort = await respuestas.next;

    Map<String, dynamic> meta = {};

    for (var i = 0; i < fotos.length; i++) {

      msgExport.value = {'msg':'Decodificando Imagen', 'num_foto':i+1, 'path':fotos[i].path};
      bool enviar = true;

      if(imageFileListProcess.isNotEmpty) {
        final has = imageFileListProcess.where((element) => element['path'] == fotos[i].path);
        if(has.isNotEmpty) {
          if(has.first['sended']) {
            enviar = false;
            imageFileListOks[has.first['indexPza']]['sended'] = has.first['sended'];
          }
        }
      }

      if(enviar) {
        
        if(imageFileListOks.isEmpty) {
          yield {'error':true};
        }
        meta['filename']= imageFileListOks[i]['filename'];
        meta['path'] = fotos[i].path;
        // Enviamos solo para determinar si la img es horizontal o no.
        sendPort.send(json.encode(meta));
        meta = await respuestas.next;
        if(meta['isHorizontal']) {
          meta['bytes'] = await _comprimirHorizontal(meta['bytes']);
        }else{
          meta['bytes'] = await _comprimirVertical(meta['bytes']);
        }

        if(!meta.containsKey('idTmp')) { meta['idTmp'] = idTmp; }
        meta['sended']  = false;
        meta['token']   = tokenServer;
        meta['indexPza']= i;
        meta['idOrden']= idOrden;
        // Enviamos al servidor desde el isolate
        sendPort.send(json.encode(meta));
        meta = await respuestas.next;
        msgExport.value = {'msg':'Enviando Imagen', 'num_foto':i+1};
        yield meta;
      }

      sendPort.send('clean');
      meta = await respuestas.next;
    }

    sendPort.send('fin');
    await respuestas.cancel();
    msgExport.value = {'msg':'Listo', 'num_foto':0};
  }

  ///
  Future<Uint8List> _comprimirHorizontal(Uint8List list) async {

    return await FlutterImageCompress.compressWithList(
      list, minWidth: minSize, quality: 72
    );
  }

  ///
  Future<Uint8List> _comprimirVertical(Uint8List list) async {

    return await FlutterImageCompress.compressWithList(
      list, minHeight: minSize, quality: 72
    );
  }

  ///
  Future<void> _addFotosToList(XFile listaFts) async {

    int cantCurrent = imageWebList.length + imageFileList.length;
    if(fotosFromServer.isNotEmpty) {
      cantCurrent = cantCurrent + fotosFromServer.length;
    }

    if(cantCurrent < maxPermitidas) {
      imageFileList.add(listaFts);
      refreshPage.value = 'refreshPage';
    }
  }

  ///
  Future<String> getIdTmpFromFileName(String filename) async {

    List<String> partes = filename.split('-');
    partes.removeLast();
    return partes.last;
  }

  ///
  Widget errSelectImg(bool hasError) {

    if (hasError) {
      return const Text(
        'Error de selección de imagen.',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Aún no has elegido una imagen.',
        textAlign: TextAlign.center,
      );
    }
  }

}