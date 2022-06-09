import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import '../pages/home/data_shared/ds_repo.dart';

class ReposProcesoProv extends ChangeNotifier {

  final DsRepo dsRepo = getSngOf<DsRepo>();
  bool hasNotif = false;
  // El puntero indica el Key del repo que tenemos seleccionado actualmente.
  int puntero = -1;
  int indexDelpuntero = -1;
  // Contiene todas las key existentes de Box<Orden> con status x seccion proceso
  final List<int> _allKeys = [];
  List<int> get allKeys => _allKeys;
  set addallKeys(List<int> keys) {
    _allKeys.clear();
    _allKeys.addAll(keys);
  }
  set addToKeys(int newkey) {
    if (!_allKeys.contains(newkey)) {
       _allKeys.add(newkey);
    }
  }

  ///
  Map<String, dynamic> inSceneRepo = {};
  Future<void> setInSceneByKeyRepo(int keyRepo) async {
    if(keyRepo == -1) {
      keyRepo = allKeys.last;
    }
    puntero = keyRepo;
    indexDelpuntero = allKeys.indexOf(keyRepo);
    inSceneRepo = await dsRepo.getOrdenFromEntityToMapBy(0, keyOrden: keyRepo);
    setKeyReposVistos(keyRepo);
  }

  // Indica los repositorios ya vistos en pantalla
  final List<int> _keysRepoVistos = [];
  List<int> get keysRepoVistos => _keysRepoVistos;
  void setKeyReposVistos(int keyRepo) {
    if(!keysRepoVistos.contains(keyRepo)){
      keysRepoVistos.add(keyRepo);
    }
    notifyListeners();
  }

  ///
  Future<void> showNextRepo() async {

    indexDelpuntero = indexDelpuntero +1;
    if(indexDelpuntero > (allKeys.length - 1)) {
      indexDelpuntero = 0;
    }
    setInSceneByKeyRepo(allKeys[indexDelpuntero]);
  }

  ///
  Future<void> showPreviewRepo() async {

    indexDelpuntero = indexDelpuntero -1;
    if(indexDelpuntero < 0) {
      indexDelpuntero = (allKeys.length -1);
    }
    setInSceneByKeyRepo(allKeys[indexDelpuntero]);
  }

  ///
  Future<void> eliminarRepoByKey(int key, {bool showNext = true}) async {

    inSceneRepo = {};
    _allKeys.remove(key);
    _keysRepoVistos.remove(key);
    if(_allKeys.isNotEmpty) {
      await showNextRepo();
    }
    notifyListeners();
  }

}