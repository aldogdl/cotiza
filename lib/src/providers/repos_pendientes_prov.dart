import 'package:autoparnet_cotiza/src/entity/orden.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import '../entity/repo_main.dart';
import '../pages/home/data_shared/ds_repo.dart';

class ReposPendientesProv extends ChangeNotifier {

  final DsRepo dsRepo = getSngOf<DsRepo>();
  
  // El puntero indica el Key del repo que tenemos seleccionado actualmente.
  int puntero = -1;
  int indexDelpuntero = -1;
  // Contiene todas las key de Box<RepoMain> con status 0 y 1 que nos indica la
  // cantidad de Repos incompletos
  final List<int> _allKeys = [];
  List<int> get allKeys => _allKeys;
  set addallKeys(List<int> ids) {
    _allKeys.clear();
    _allKeys.addAll(ids);
  }
  set addToKeys(int id) => _allKeys.add(id);

  ///
  Map<String, dynamic> inSceneRepo = {};
  Future<void> setInSceneByKey(int keyOrden) async {
    if(keyOrden == -1) {
      keyOrden = allKeys.last;
    }
    puntero = keyOrden;
    indexDelpuntero = allKeys.indexOf(keyOrden);
    inSceneRepo = await dsRepo.getOrdenFromEntityToMapBy(0, keyOrden: keyOrden);
    await setKeyReposVistos(keyOrden);
  }

  // Indica los repositorios ya vistos en pantalla
  final List<int> _keysRepoVistos = [];
  List<int> get keysRepoVistos => _keysRepoVistos;
  Future<void> setKeyReposVistos(int keyRepo) async {
    if(!keysRepoVistos.contains(keyRepo)){
      keysRepoVistos.add(keyRepo);
    }
    notifyListeners();
  }

  ///
  Future<int> getNextRepo() async {

    if(allKeys.isNotEmpty) {
      int indexpunteroTmp = indexDelpuntero +1;
      if(indexpunteroTmp > (allKeys.length - 1)) {
        indexpunteroTmp = 0;
      }
      return allKeys[indexpunteroTmp];
    }
    return -1;
  }

  ///
  Future<void> showNextRepo() async {

    if(allKeys.isNotEmpty) {
      indexDelpuntero = indexDelpuntero +1;
      if(indexDelpuntero > (allKeys.length - 1)) {
        indexDelpuntero = 0;
      }
      await setInSceneByKey(allKeys[indexDelpuntero]);
    }else{
      inSceneRepo = {};
    }
  }

  ///
  Future<int> getPreviewRepo() async {

    int indexpunteroTmp = indexDelpuntero -1;
    if(indexpunteroTmp < 0) {
      indexpunteroTmp = (allKeys.length -1);
    }
    return allKeys[indexpunteroTmp];
  }

  ///
  Future<void> showPreviewRepo() async {

    if(allKeys.isNotEmpty) {
      indexDelpuntero = indexDelpuntero -1;
      if(indexDelpuntero < 0) {
        indexDelpuntero = (allKeys.length -1);
      }
      await setInSceneByKey(allKeys[indexDelpuntero]);
    }else{
      inSceneRepo = {};
    }
  }

  /// keyNew el key de la nueva Orden agregado desde Adicionar auto,
  Future<int> addNewRepoMainToScreen(dynamic keyNew) async {

    Orden? newOrden = dsRepo.orden.get(keyNew);
    if(newOrden != null) {
      addToKeys = newOrden.id;
      await setInSceneByKey(newOrden.key);
      return newOrden.id;
    }else{
      return 0;
    }
  }

  ///
  Future<int> eliminarCurrentPendiente({bool deleteFull = true}) async {

    int idOrden = inSceneRepo['idMain'];
    Orden orden = dsRepo.orden.values.firstWhere(
      (main) => main.id == idOrden, orElse: () => Orden()
    );
    idOrden = orden.id;
    if(idOrden != 0) {

      inSceneRepo = {};
      _allKeys.remove(orden.key);
      _keysRepoVistos.remove(orden.key);
      if(deleteFull) {
        dsRepo.orden.delete(orden.key);
        dsRepo.orden.compact();
      }
      if(_allKeys.isNotEmpty) {
        showNextRepo();
      }else{
        notifyListeners();
      }
    }
    return idOrden;
  }

  ///
  Future<int> eliminarPendienteByKey(int key) async {

    RepoMain repo = dsRepo.repoMain.values.firstWhere(
      (main) => main.key == key, orElse: () => RepoMain(0, 0, DateTime.now())
    );

    int idMain = repo.id;
    if(repo.id != 0) {
      
      inSceneRepo = {};
      _allKeys.remove(repo.key);
      _keysRepoVistos.remove(repo.key);
      if(_allKeys.isNotEmpty) {
        showNextRepo();
      }else{
        notifyListeners();
      }
    }
    return idMain;
  }

}