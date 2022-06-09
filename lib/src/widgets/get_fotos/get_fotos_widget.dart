import 'package:autoparnet_cotiza/src/repository/repos_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'get_fotos_movil.dart';
import 'get_fotos_web.dart';
import 'singleton/picker_pictures.dart';

class GetFotosWidget extends StatelessWidget {

  final ValueChanged<List<XFile>> onFinish;
  final BoxConstraints constraints;
  final int cantMax;
  final int idOrden;
  final String theme;

  GetFotosWidget({
    required this.constraints,
    required this.onFinish,
    required this.cantMax,
    required this.idOrden,
    this.theme = 'light',
    Key? key 
  }) : super(key: key);

  final globals = getSngOf<Globals>();
  final RepoRepository _repoEm = RepoRepository();
  final PickerPictures picktures = getSngOf<PickerPictures>();
  
  @override
  Widget build(BuildContext context) {
    
    return (!kIsWeb)
      ? GetFotosMovil(
        cantMax: cantMax,
        idOrden: idOrden,
        constraints: constraints,
        theme: theme,
        onDelete: (data) async => await _accionDeleteFoto(data),
      )
      : GetFotosWeb(
        cantMax: cantMax,
        idOrden: idOrden,
        constraints: constraints,
        onDelete: (data) async => await _accionDeleteFoto(data),
      );
  }

  ///
  Future<void> _accionDeleteFoto(Map<String, dynamic> data) async {

    bool delFromServer = false;
    String delFilename = '';
    int indexP = -1;

    if(data['from'] == 'xfile') {

      if(picktures.imageFileList.isNotEmpty) {
        picktures.imageFileList.removeWhere((element) => element.path == data['path']);
      }
      if(picktures.imageFileListProcess.isNotEmpty) {
        indexP = picktures.imageFileListProcess.indexWhere((element) => element['path'] == data['path']);
        if(indexP != -1) {
          if(picktures.imageFileListProcess[indexP]['sended']) {
            delFromServer = true;
            delFilename = picktures.imageFileListProcess[indexP]['filename'];
          }
          picktures.imageFileListProcess.removeAt(indexP);
        }
      }

      if(picktures.imageFileListOks.isNotEmpty) {
        indexP = picktures.imageFileListOks.indexWhere((element) => element['path'] == data['path']);
        if(indexP != -1) {
          if(picktures.imageFileListOks[indexP]['sended']) {
            delFromServer = true;
            delFilename = picktures.imageFileListOks[indexP]['filename'];
          }
          picktures.imageFileListOks.removeAt(indexP);
        }
      }
      
    }else{

      if(picktures.fotosFromServer.isNotEmpty) {
        if(!picktures.fotosFromServerDel.contains(data['filename'])) {
          picktures.fotosFromServerDel.add(data['filename']);
        }
        delFromServer = true;
        delFilename = data['filename'];
        picktures.fotosFromServer.remove(data['filename']);
      }

      if(picktures.imageFileListOks.isNotEmpty) {
        indexP = picktures.imageFileListOks.indexWhere((element) => element['filename'] == data['filename']);
        if(indexP != -1) {
          if(picktures.imageFileListOks[indexP]['sended']) {
            delFromServer = true;
            delFilename = picktures.imageFileListOks[indexP]['filename'];
          }
          picktures.imageFileListOks.removeAt(indexP);
        }
      }
    }

    imageCache.clear();
    if(delFromServer) {
      await _repoEm.delImgOfOrdenTmp(delFilename);
    }
  }
}