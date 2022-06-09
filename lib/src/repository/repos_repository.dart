import 'package:hive_flutter/adapters.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/boxes_names.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/type_ids.dart';

import '../entity/orden_piezas.dart';
import '../entity/orden.dart';
import '../entity/repo_pizas.dart';
import '../services/get_uris.dart';
import '../services/my_http.dart';
import '../pages/home/data_shared/ds_repo.dart';

class RepoRepository {

  final Globals globals = getSngOf<Globals>();
  final DsRepo _dsRepo = getSngOf<DsRepo>();
  MyHttp http = MyHttp();

  Map<String, dynamic> result = {'abort':false, 'msg': 'ok', 'body': ''};

  ///
  void cleanResult() { 
    result = {'abort': false, 'msg':'ok', 'body':[]};
    http.cleanResult();
  }

  /// 
  Future<String> getTokenServer() async {
    if(http.tokenServer.isEmpty) {
      await http.getTokenServer();
    }
    return http.tokenServer;
  }

  ///
  Future<void> getOrdenesByIdUserAndSeccion(int idUser, String seccion) async {

    String uri = GetUris.getUriBy('ordenes_by_seccion');
    await http.getD('$uri$idUser/$seccion/');
    result = http.result;
  }

  ///
  Future<void> getPiezasByLstOrdenes(String lstOrdenes) async {

    String uri = GetUris.getUriBy('pzas_by_lstOrdenes');
    await http.getD('$uri$lstOrdenes/');
    result = http.result;
  }

  ///
  Future<void> getRespuestasByIdMain(int idRepoMain) async {

    String uri = GetUris.getUriBy('get_respuestas_xcot');
    await http.getD('$uri$idRepoMain');
    result = http.result;
    http.cleanResult();
  }

  ///
  Future<List<Map<String, dynamic>>> getPiezasRegistradas({bool forList = true}) async {

    List<Map<String, dynamic>> pzas = [];
    await _dsRepo.openBoxPzaReg();
    
    _dsRepo.pzaReg.values.map((e) {
      if(!pzas.contains(e.toJsonToFrm())) {
        pzas.add(e.toJsonToFrm());
      }
    }).toList();
    return pzas;
  }

  ///
  Future<void> buildNewOrden(Map<String, dynamic> orden) async {

    String uri = GetUris.getUriBy('set_orden');
    await http.postD(uri, orden);
    result = http.result;
    return;
  }

  /// Guardmos los autos y la orden traidos desde el servidor
  Future<void> saveOrdenesFromServerInBdLocal(List<Map<String, dynamic>> ordenes) async {

    // Revisar los autos guardados y salvar los que no existan.
    await _dsRepo.openBoxOrden();

    for (var i = 0; i < ordenes.length; i++) {

      Orden ordObj = Orden()..fromServerMap(ordenes[i]);

      // Revisar los repos main guardados y salvar los que no existan.
      Iterable<Orden?> ordenIn = _dsRepo.orden.values.where((main) => main.id == ordObj.id);
      if(ordenIn.isEmpty) {
        // Guardamos main inexistente.
        _dsRepo.orden.add(ordObj);
      }else{
        // Editamos el encontrado
        _dsRepo.orden.put(ordenIn.first!.key, ordObj);
        _dsRepo.orden.get(ordenIn.first!.key)!.save();
      }
    }

    return;
  }

  /// Guardmos los autos y la orden traidos desde el servidor
  Future<void> setPiezasFromServerToBdLocal(List<Map<String, dynamic>> piezas) async {

    // Revisar los autos guardados y salvar los que no existan.
    await _dsRepo.openBoxOrdenPzas();
    
    for (var i = 0; i < piezas.length; i++) {

      OrdenPiezas pzaObj = OrdenPiezas()..fromServerMap(piezas[i]);

      // Revisar piezas guardadas y salvar las que no existan.
      Iterable<OrdenPiezas?> piezasIn = _dsRepo.ordenPzas.values.where((pza) => pza.id == pzaObj.id);
      if(piezasIn.isEmpty) {
        // Guardamos pieza inexistente.
        _dsRepo.ordenPzas.add(pzaObj);
      }else{
        // Editamos el encontrado
        _dsRepo.ordenPzas.put(piezasIn.first!.key, pzaObj);
        _dsRepo.ordenPzas.flush();
      }
      
      final estStt = _dsRepo.sttEm.getStatusConPiezas();
      await _dsRepo.sttEm.changeSttToOrden(estStt);
    }

    return;
  }

  ///
  Future<OrdenPiezas?> getPiezasInLocalByKey(int key) async {

    await _dsRepo.openBoxOrdenPzas();
    Iterable<OrdenPiezas?> piezasIn = _dsRepo.ordenPzas.values.where((pza) => pza.key == key);
    if(piezasIn.isNotEmpty) {
      return piezasIn.first;
    }
    return null;
  }

  ///
  Future<bool> savePzaToServer(Map<String, dynamic> pza) async {

    String uri = GetUris.getUriBy('set_pieza');
    await http.postD(uri, pza);
    result = http.result;
    return !http.result['abort'];
  }

  ///
  Stream<Map<String, int>> sendPzaStream(List<Map<String, dynamic>> piezas) async* {

    for (var i = 0; i < piezas.length; i++) {
      if(!piezas[i]['saved']) {
        
        final pza = _dsRepo.ordenPzas.get(piezas[i]['key']);
        if(pza != null) {
          bool saved = await savePzaToServer(pza.toJson());
          if(saved) {
            pza.est = result['body']['est'];
            pza.stt = result['body']['stt'];
            pza.box!.flush();
            yield <String, int>{'key':int.parse('${piezas[i]['key']}'), 'id':result['body']['id']};
          }else{
            yield {'key':-1, 'id':0};
          }
        }
      }
    }
  }

  ///
  Future<bool> deletePiezaAntesDeSave(int idPza) async {

    String uri = GetUris.getUriBy('del_pieza');
    await http.getD('$uri$idPza/');
    result = http.result;
    return !http.result['abort'];
  }

  ///
  Future<void> savePiezasInBdLocal(
    int idMain,
    int keyRepoMain,
    List<Map<String, dynamic>> piezas
  ) async {

    if(!Hive.isAdapterRegistered(TypeIds.tiRpiezas)) {
      Hive.registerAdapter<RepoPizas>(RepoPizasAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.repoPzasBox)) {
      await Hive.openBox<RepoPizas>(BoxesNames.repoPzasBox);
    }
    Box<RepoPizas> repoPiezas = Hive.box<RepoPizas>(BoxesNames.repoPzasBox);
    
    for (var p = 0; p < piezas.length; p++) {

      RepoPizas newPza = RepoPizas(
        id   : piezas[p]['pzas_id'],
        idTmp: int.parse(piezas[p]['pzas_idTmp']),
        repo : idMain,
        cant : piezas[p]['pzas_cant'],
        pieza: piezas[p]['pzas_pieza'],
        ubik : piezas[p]['pzas_lugar'],
        notas: piezas[p]['pzas_notas'],
        fotos: List<String>.from(piezas[p]['pzas_fotos']),
        statusId: piezas[p]['st_id'],
        statusNom: piezas[p]['st_nombre'],
        posicion  : piezas[p]['pzas_posicion'],
        precioLess: double.parse('${piezas[p]['pzas_precioLess']}'),
      );
      
      Iterable<RepoPizas?> hasPieza = repoPiezas.values.where((pza) => pza.id == newPza.id);
      if(hasPieza.isEmpty) {
        // Guardamos main inexistente.
        repoPiezas.add(newPza);
      }else{
        // Editamos el encontrado
        repoPiezas.put(hasPieza.first!.key, newPza);  
      }
    }
  }

  ///
  Future<String> deleteOrdenFromServer(int idOrden) async {

    String uri = GetUris.getUriBy('delete_orden');
    await http.getD('$uri$idOrden');
    return 'ok';
  }

  ///
  Future<void> enviarOrden(int idOrden) async {

    String uri = GetUris.getUriBy('enviar_orden');
    await http.getD('$uri$idOrden');
    result = http.result;
  }

  /// Enviamos el archivo para revisar al compartir imagenes entre dispositivos
  Future<void> sendFileForShareFotosFromDevice(Map<String, dynamic> data) async {

    String uri = GetUris.getUriBy('setFileShare_device');
    await http.postD(uri, data);
    result = http.result;
    http.cleanResult();
  }

  /// Borramos la foto indicada en el servidor
  Future<void> delImgOfOrdenTmp(String filename) async {

    String uri = GetUris.getUriBy('delImg_of_orden_tmp');
    await http.getD('$uri$filename');
  }

  /// Checamos el archivo creado para compartir fotos
  Future<void> checkFileShareFotos(String filename, String tipoChequeo) async {

    String uri = GetUris.getUriBy('checkShare_imgDevice');
    await http.getD('$uri$filename/$tipoChequeo/');
    result = http.result;
  }

  /// Borramos el archivo creado para compartir fotos
  Future<void> removeFileShareFotos(String filename) async {

    String uri = GetUris.getUriBy('delShare_imgDevice');
    await http.getD('$uri$filename/');
    result = http.result;
  }

  /// Abrimos desde el movil el archivo de compartir fotos.
  Future<void> openFileShareFotosFromDevice(String filename) async {

    String uri = GetUris.getUriBy('openShare_imgDevice');
    await http.getD('$uri$filename/');
    result = http.result;
    http.cleanResult();
  }

  /// Abrimos desde el movil el archivo de compartir fotos.
  Future<void> notificarFinSharedImgs(String filename) async {

    String uri = GetUris.getUriBy('finShare_imgDevice');
    await http.getD('$uri$filename/');
    result = http.result;
    http.cleanResult();
  }

  ///
  Future<void> deleteFotoShared(String nameFoto, int idMain) async {

    String uri = GetUris.getUriBy('delete_fotos_shared');
    await http.getD('$uri$nameFoto/$idMain/');
    result = http.result;
  }

  ///
  Future<void> sendPedidoToSCP(List<Map<String, dynamic>> data) async {

    String uri = GetUris.getUriBy('save_repo_pedido');
    await http.postD(uri, {'data':data});
    
    result = http.result;
  }

  ///
  Future<void> sendPushPedidoToSCP(int idMain) async {
    String uri = GetUris.getUriBy('send_push_pedido');
    await http.getD('$uri$idMain');
    result = http.result;
  }

  ///
  Future<void> sendPushLeida(int idRepoMain) async {

    if(!globals.idsRepoLeida.contains(idRepoMain)) {
      globals.idsRepoLeida.add(idRepoMain);
      String uri = GetUris.getUriBy('send_push_leida');
      http.getD('$uri$idRepoMain');
    }
    http.cleanResult();
  }
  
}