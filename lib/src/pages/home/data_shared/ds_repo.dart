import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/boxes_names.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/type_ids.dart';

import '../../../entity/orden_piezas.dart';
import '../../../entity/piezas_reg.dart';
import '../../../entity/user_admin.dart';
import '../../../entity/orden.dart';
import '../../../entity/repo_info.dart';
import '../../../entity/repo_pizas.dart';
import '../../../entity/marcas.dart';
import '../../../entity/modelos.dart';
import '../../../entity/repo_auto.dart';
import '../../../entity/repo_main.dart';
import '../../../repository/stt_repository.dart';
import '../../../providers/btn_send_cotizacion_prov.dart';
import '../../../providers/pestanias_prov.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../providers/repos_proceso_prov.dart';
import '../../../providers/repos_pendientes_prov.dart';

class DsRepo {

  DsRepo() { initConfig(); }

  final Globals globals = getSngOf<Globals>();
  final SttRepository sttEm = SttRepository();

  late Box<UserAdmin> user;
  late Box<Marcas> marcas;
  late Box<Modelos> modelos;
  late Box<Orden> orden;
  late Box<OrdenPiezas> ordenPzas;
  late Box<PiezasReg> pzaReg;

  late Box<RepoAuto> repoAuto;
  late Box<RepoMain> repoMain;
  late Box<RepoInfo> repoInfo;
  late Box<RepoPizas> repoPzas;

  // Usado para saber cual de los repos que se encuentran en proceso esta
  // actualmente seleccionado para visualizar sus piezas.
  int idRepoMainSelectCurrent = 0;
  String fromIdRepo = '0';
  //String msgLoad = 'Buscando Recientes';
  double maxH = 0;
  double maxW = 0;

  ///
  Future<void> cleanBds() async {

    await Hive.deleteBoxFromDisk(BoxesNames.repoInfoBox);
    await Hive.deleteBoxFromDisk(BoxesNames.repoPzasBox);
    await Hive.deleteBoxFromDisk(BoxesNames.repoMainBox);
    await Hive.deleteBoxFromDisk(BoxesNames.repoAutoBox);
    await Hive.deleteBoxFromDisk(BoxesNames.ordenBox);
    await Hive.deleteBoxFromDisk(BoxesNames.modelosBox);
    await Hive.deleteBoxFromDisk(BoxesNames.marcasBox);
    await Hive.deleteBoxFromDisk(BoxesNames.puchesBox);
    await Hive.deleteBoxFromDisk(BoxesNames.userAdminBox);
    await Hive.deleteBoxFromDisk(BoxesNames.statusBox);
  }

  ///
  Future<void> initBoxForSplash() async {

    await openBoxMarcas();
    await openBoxOrden();
  }

  ///
  Future<void> initAutos() async {
    await openBoxMarcas();
    await openBoxModelos();
  }

  ///
  Future<void> initConfig() async {

    await openBoxMarcas();
    await openBoxModelos();
    await openBoxOrden();
    await openBoxOrdenPzas();
  }

  ///
  Future<Map<String, dynamic>> getOrdenFromEntityToMapBy(
    int idOrden, { int? keyOrden }
  ) async {

    Map<String, dynamic> ordenMap = {};
    Orden? entity;
    if(keyOrden != null) {
      entity = orden.get(keyOrden);
    }else{
      Iterable<Orden>? ultimaOrden = orden.values.where((ord) => ord.id == idOrden);
      if(ultimaOrden.isNotEmpty) {
        entity = ultimaOrden.first;
        ultimaOrden = null;
      }
    }

    if(entity != null) {
      await openBoxMarcas();
      await openBoxModelos();
      Iterable<Marcas>? mrkBox = marcas.values.where((mrk) => mrk.id == entity!.marca);      
      Iterable<Modelos>? mdlBox = modelos.values.where((mdl) => mdl.id == entity!.modelo);
      
      int cantPzas = 0;
      await openBoxOrdenPzas();
      if(ordenPzas.values.isNotEmpty) {
        ordenPzas.values.map((e) {
          if(e.orden == entity!.id) {
            cantPzas++;
          }
        }).toList();
      }

      ordenMap = {
        'key'   : entity.key,
        'idMain': entity.id,
        'creada': entity.createdAt,
        'marca' : mrkBox.first.marca,
        'modelo': mdlBox.first.modelo,
        'anio'  : entity.anio,
        'logo'  : mrkBox.first.logo,
        'cantPzs': cantPzas,
        'est'    : entity.est,
        'stt'    : entity.stt,
        'nac'    : (entity.isNac) ? 'NACIONAL' : 'IMPORTADO',
      };
      mrkBox = null;
      mdlBox = null;
    }
    
    return ordenMap;
  }

  ///
  Future<Orden?> getOrdenToEntity(int idOrden) async {

    Orden? entity;
    Iterable<Orden>? ultimaOrden = orden.values.where((ord) => ord.id == idOrden);
    if(ultimaOrden.isNotEmpty) {
      entity = ultimaOrden.first;
    }
    return entity;
  }

  ///
  RepoMain? getRepoMainByKey(int key) => repoMain.get(key);

  ///
  RepoPizas? getRepoPizaByKey(int key) => repoPzas.get(key);

  ///
  Future<int> getKeyRepoMainById(int idOrden) async {

    Iterable<Orden> has = orden.values.where((e) => e.id == idOrden);
    if(has.isNotEmpty) {
      return has.first.key;
    }
    return -1;
  }

  ///
  Future<int> getKeyRepoPzaById(int idPza) async {

    Iterable<RepoPizas> has = repoPzas.values.where((e) => e.id == idPza);
    if(has.isNotEmpty) {
      return has.first.key;
    }
    return -1;
  }

  /// Calculamos las piezas, repuestas y el menor costo del repoMain
  /// por medio de su ID
  Future<Map<String, dynamic>> buildPieCardDataEnProceso(int idOrden) async {

    Map<String, dynamic> resp = {
      'pzas': 0, 'resp': 0, 'precioLess': 0.0
    };
    
    await openBoxOrdenPzas();
    if(ordenPzas.isNotEmpty) {
      if(ordenPzas.values.isNotEmpty) {
        List<int> keyPzas = List<int>.from(ordenPzas.keys);
        for (var i = 0; i < keyPzas.length; i++) {
          OrdenPiezas? pz = ordenPzas.get(keyPzas[i]);
          if(pz != null) {
            if(pz.orden == idOrden) {
              resp['pzas'] = resp['pzas'] + 1;
            }
          }
        }
      }
    }
    return resp;
  }

  /// 
  Future<void> openBoxUserAdmin() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiUserAd)) {
      Hive.registerAdapter<UserAdmin>(UserAdminAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.userAdminBox)){
      user = await Hive.openBox<UserAdmin>(BoxesNames.userAdminBox);
    }else{
      user = Hive.box(BoxesNames.userAdminBox);
    }
  }

  /// 
  Future<void> openBoxMarcas() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiMarcas)) {
      Hive.registerAdapter<Marcas>(MarcasAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.marcasBox)){
      marcas = await Hive.openBox<Marcas>(BoxesNames.marcasBox);
    }else{
      marcas = Hive.box(BoxesNames.marcasBox);
    }
  }

  /// 
  Future<void> openBoxModelos() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiModelos)) {
      Hive.registerAdapter<Modelos>(ModelosAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.modelosBox)){
      modelos = await Hive.openBox<Modelos>(BoxesNames.modelosBox);
    }else{
      modelos = Hive.box(BoxesNames.modelosBox);
    }
  }

  /// 
  Future<void> openBoxOrden() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiOrden)) {
      Hive.registerAdapter<Orden>(OrdenAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.ordenBox)){
      orden = await Hive.openBox<Orden>(BoxesNames.ordenBox);
    }else{
      orden = Hive.box(BoxesNames.ordenBox);
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// 
  Future<void> openBoxOrdenPzas() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiOrdPzas)) {
      Hive.registerAdapter<OrdenPiezas>(OrdenPiezasAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.ordenPzasBox)){
      ordenPzas = await Hive.openBox<OrdenPiezas>(BoxesNames.ordenPzasBox);
    }else{
      ordenPzas = Hive.box(BoxesNames.ordenPzasBox);
    }
  }

  /// 
  Future<void> openBoxPzaReg() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiPzReg)) {
      Hive.registerAdapter<PiezasReg>(PiezasRegAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.pzReg)){
      pzaReg = await Hive.openBox<PiezasReg>(BoxesNames.pzReg);
    }else{
      pzaReg = Hive.box(BoxesNames.pzReg);
    }
  }

  /// 
  Future<void> openBoxAuto() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiRauto)) {
      Hive.registerAdapter<RepoAuto>(RepoAutoAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.repoAutoBox)){
      repoAuto = await Hive.openBox<RepoAuto>(BoxesNames.repoAutoBox);
    }else{
      repoAuto = Hive.box(BoxesNames.repoAutoBox);
    }
  }

  ///
  Future<void> openBoxMain() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiRmain)) {
      Hive.registerAdapter<RepoMain>(RepoMainAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.repoMainBox)){
      repoMain = await Hive.openBox<RepoMain>(BoxesNames.repoMainBox);
    }else{
      repoMain = Hive.box(BoxesNames.repoMainBox);
    }
  }

  ///
  Future<void> openBoxPiezas() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiRpiezas)) {
      Hive.registerAdapter<RepoPizas>(RepoPizasAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.repoPzasBox)) {
      repoPzas = await Hive.openBox<RepoPizas>(BoxesNames.repoPzasBox);
    }else{
      repoPzas = Hive.box<RepoPizas>(BoxesNames.repoPzasBox);
    }
  }

  ///
  Future<void> openBoxInfo() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiRinfo)) {
      Hive.registerAdapter(RepoInfoAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.repoInfoBox)) {
      repoInfo = await Hive.openBox(BoxesNames.repoInfoBox);
    }
  }

  /// Agregamos o borramos la respuesta seleccionada al pedido
  Future<void> setRespuestaPedido({
    required int id,
    required int idPza,
    required int idRepo,
    required double precio,
    bool insert = true
  }) async {

    RepoInfo newItem = RepoInfo(id: id, idPza: idPza, idRepo: idRepo, precio: precio);
    if(repoInfo.isEmpty && insert) {
      repoInfo.add(newItem);
    }else{
      Iterable<RepoInfo> has = repoInfo.values.where((element) => element.id == id);
      if(has.isEmpty){
        if(insert) {
          repoInfo.add(newItem);
        }
      }else{
        if(!insert) {
          repoInfo.delete(has.first.key);
        }
      }
    }
  }

  /// recuperamos las respuesta seleccionadas para el pedido
  Future<List<int>> getRespuestaByIdRepoSelect() async {

    List<int> resps = [];
    Iterable<RepoInfo> has = repoInfo.values.where((e){
      return e.idRepo == idRepoMainSelectCurrent;
    });
    if(has.isNotEmpty){
      has.map((e) => resps.add(e.id!)).toList();
    }
    return resps;
  }

  /// recuperamos las respuesta seleccionadas para el pedido
  Future<Map<String, dynamic>> getRespuestaPedidoForSend() async {

    Map<String, dynamic> resps = {
      'monto': 0,
      'data' : []
    };
    Iterable<RepoInfo> has = repoInfo.values.where((e){
      return e.idRepo == idRepoMainSelectCurrent;
    });
    List<Map<String, dynamic>> dataSend = [];
    double monto = 0;
    if(has.isNotEmpty){
      has.map((e) {
        monto = monto + (e.precio ?? 0);
        dataSend.add({
          'info': e.id,
          'pza' : e.idPza,
          'main': idRepoMainSelectCurrent
        });
      }).toList();
      resps['monto'] = monto;
      resps['data'] = dataSend;
    }

    return resps;
  }

  ///
  Future<void> cambiarRepoFromProcesoToPedidos(BuildContext context, int keyRepoMain) async {

    final rProceso = context.read<ReposProcesoProv>();

    // Quitar de la scene de en proceso
    await rProceso.eliminarRepoByKey(keyRepoMain, showNext: false);
    int newKeyInScene = -1;
    int status = 3;

    // Buscar un repoMain con status mas alto para colocarlo en la escena de
    // en procesos.
    repoMain.values.map((e) {
      if(e.statusId >= 3 && e.statusId <= 6) {
        if(e.statusId > status) {
          status = e.statusId;
          newKeyInScene = e.key;
        }
      }
    }).toList();

    if(newKeyInScene > -1) {
      rProceso.addToKeys = newKeyInScene;
      rProceso.setInSceneByKeyRepo(newKeyInScene);
    }
    // colocar en la scene de pedidos
    idRepoMainSelectCurrent = 0;
  }

  /// 
  Future<void> isSameRepoSelect(BuildContext context, {int idOrdenS = -1}) async {

    final orden = context.read<ReposPendientesProv>();
    int idOrden = (idOrdenS == -1) ? orden.inSceneRepo['idMain'] : idOrdenS;
    
    if(idRepoMainSelectCurrent != idOrden) {

      idRepoMainSelectCurrent = idOrden;
      if(context.read<PestaniasProv>().pestaniaSelect == 'Cotizar') {
        await putNewPiezasInProvider(context);       
      }
    }
  }

  /// Colocamos las piezas encontradas de la orden en la seccion de piezas para enviar
  Future<void> putNewPiezasInProvider(BuildContext context) async  {

    final ctx = context;
    final prov = ctx.read<PzasToCotizarProv>();
    prov.removeAllKeyPiezas();
    prov.clearPzaToSend();
    await openBoxOrden();
    await openBoxOrdenPzas();
    if(ordenPzas.values.isNotEmpty) {

      List<int> keyInDb = [];
      for (var pza in ordenPzas.values) {
        if(pza.orden == idRepoMainSelectCurrent) {
          if(!keyInDb.contains(pza.key)) {
            keyInDb.add(pza.key);
          }
          prov.addPzaToSend(pza);
        }
      }

      if(keyInDb.isNotEmpty) {
        prov.setKeysPiezas(keyInDb);
      }
      
      keyInDb = [];
    }
  }

  /// 
  Future<void> putSttOrdenAndBtnSendActive(BuildContext context) async  {

    final ctx = context;
    final p1 = ctx.read<PzasToCotizarProv>();
    final p2 = ctx.read<BtnSendCotizacionProv>();

    Map<String, String> newStatus = {};
    await openBoxOrden();
    Orden? ord = await getOrdenToEntity(idRepoMainSelectCurrent);

    if(p1.keysPiezas.isEmpty) {
      p2.activeBtnSend = false;
      if(ord != null) {
        newStatus = sttEm.getStatusSinPiezas();
      }
    }else{
      p2.activeBtnSend = true;
      if(ord != null) {
        newStatus = sttEm.getStatusConPiezas();
      }
    }

    if(newStatus.isNotEmpty) {
      ord!.est = newStatus['est']!;
      ord.stt = newStatus['stt']!;
      ord.save();
    }
  }

}