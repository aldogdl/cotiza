import 'package:hive_flutter/adapters.dart';

import 'package:autoparnet_cotiza/vars/boxes_names.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';

import '../entity/marcas.dart';
import '../entity/modelos.dart';
import '../services/get_uris.dart';
import '../services/my_http.dart';
import '../pages/home/data_shared/ds_repo.dart';

class AutomovilRepository {

  MyHttp http = MyHttp();
  final DsRepo _dsRepo = getSngOf<DsRepo>();

  Map<String, dynamic> result = {'abort':false, 'msg': 'ok', 'body': ''};

  ///
  void cleanResult() { 
    result = {'abort': false, 'msg':'ok', 'body':[]};
    http.cleanResult();
  }

  ///
  Future<void> getAllMarcasFromServer() async {

    String uri = GetUris.getUriBy('get_all_marcas');
    http.result['abort'] = true;

    await http.getD(uri, hasToken: false);
    if(!http.result['abort']) {

      final mrks = List<Map<String, dynamic>>.from(http.result['body']);
      http.cleanResult();

      for (var i = 0; i < mrks.length; i++) {
        Marcas m = Marcas(mrks[i]['mk_id'], mrks[i]['mk_nombre'], mrks[i]['mk_logo']);
        if(!_dsRepo.marcas.values.contains(m)) {
          _dsRepo.marcas.add(m);
        }
      }
      await _dsRepo.marcas.flush();
    }
  }

  ///
  Future<Map<String, dynamic>> getModelosByIdMarca(int idMarca) async {

    String uri = GetUris.getUriBy('get_modelos_by_marca');
    await http.getD('$uri$idMarca/', hasToken: false);
    if(!http.result['abort']) {
      result = http.result;
    }
    return {};
  }

  /// Revisamos que esistan los modelos de las marcas existentes en RepoAuto
  Future<void> revisarExistMarcaAndModelos(List<Map<String, dynamic>> data) async {

    _dsRepo.openBoxMarcas();
    _dsRepo.openBoxModelos();
    for (var i = 0; i < data.length; i++) {

      await revisarExistMarca(data[i]['mk_id']);
      bool hasModelosLaMarca = await revisarExistenciaDeModelosByMarca(data[i]['mk_id']);
      
      if(!hasModelosLaMarca) {
        await getModelosByIdMarca(data[i]['mk_id']);
        if(result['body'].isNotEmpty) {
          await saveModelosInBdLocal(List<Map<String, dynamic>>.from(result['body']));
        }
      }
    }
  }

  /// Revisamos que esistan los modelos de las marcas existentes en RepoAuto
  Future<void> revisarExistMarca(int idMarca) async {

    await _dsRepo.openBoxMarcas();
    final has = _dsRepo.marcas.values.where((e) => e.id == idMarca);
    if(has.isEmpty) {
      // Descargamos las marcas
      await getAllMarcasFromServer();
    }
  }

  /// Revisamos que esistan los modelos de las marcas existentes en RepoAuto
  Future<bool> revisarExistenciaDeModelosByMarca(int idMarca) async {

    Iterable<Modelos> hasModelo = _dsRepo.modelos.values.where((mods) => mods.idMrk == idMarca);
    return (hasModelo.isEmpty) ? false : true;
  }

  /// Guardamos los modelos traidos desde el servidor en la BD local
  Future<void> saveModelosInBdLocal(List<Map<String, dynamic>> mods) async {

    Box<Modelos> modelos = Hive.box<Modelos>(BoxesNames.modelosBox);
    for (var i = 0; i < mods.length; i++) {
      Iterable<Modelos> hasModelo = modelos.values.where((mod) => mod.id == mods[i]['md_id']);
      if(hasModelo.isEmpty) {
        modelos.add(
          Modelos(mods[i]['md_id'], mods[i]['mrk_id'], mods[i]['md_nombre'])
        );
      }
    }
  }

}