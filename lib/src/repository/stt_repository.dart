import 'package:flutter/material.dart' show Color;
import 'package:hive_flutter/hive_flutter.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';

import '../pages/home/data_shared/ds_repo.dart';
import '../entity/orden.dart';
import '../entity/orden_piezas.dart';
import '../entity/status.dart';
import '../services/get_uris.dart';
import '../services/my_http.dart';
import '../../vars/boxes_names.dart';
import '../../vars/type_ids.dart';

class SttRepository {

  MyHttp http = MyHttp();
  
  late Box<Status> status;

  Map<String, dynamic> result = {'abort':false, 'msg': 'ok', 'body': ''};

  ///
  void cleanResult() { 
    result = {'abort': false, 'msg':'ok', 'body':[]};
    http.cleanResult();
  }
  
  ///
  Future<void> openBoxStatus() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiStatus)) {
      Hive.registerAdapter<Status>(StatusAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.statusBox)){
      status = await Hive.openBox<Status>(BoxesNames.statusBox);
    }else{
      status = Hive.box<Status>(BoxesNames.statusBox);
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  ///
  Future<void> recoverySttRuta() async {

    await openBoxStatus();
    await getAllStatusOrdenes();

    if(!result['abort']) {

      if(result['body'].isNotEmpty) {
        
        final stts = Map<String, dynamic>.from(result['body']);
        
        Status entity = Status();
        entity.est = Map<String, dynamic>.from(stts['est']);
        entity.stt = Map<String, dynamic>.from(stts['stt']);
        entity.ext = Map<String, dynamic>.from(stts['ext']);
        await status.add(entity);
      }
    }
    cleanResult();
  }

  ///
  Future<void> getAllStatusOrdenes() async {

    String uri = GetUris.getUriBy('get_status_ordenes');
    await http.getD(uri, hasToken: false);
    result = http.result;
  }

  ///
  Map<String, String> getStatusSinPiezas() => {'est':'1', 'stt':'1'};

  ///
  Map<String, String> getStatusConPiezas() => {'est':'1', 'stt':'2'};

  ///
  Future<String> toTexto(String est, String stt) async {

    await openBoxStatus();

    if(status.values.isNotEmpty) {

      String res = 'Sin Status';
      Status? st = status.getAt(0);
      if(st != null) {
        if(st.stt.containsKey(est)) {
          if(st.stt[est].containsKey(stt)) {
            res = st.stt[est][stt];
          }
        }
      }
      return res;
    }
    return 'En Proceso';
  }

  ///
  Color getColor(String stt) {

    Color cl = const Color.fromARGB(255, 33, 243, 68);
    if(stt.startsWith('Enviar')) {
      cl = const Color.fromARGB(255, 33, 150, 243);
    }
    return cl;
  }

  ///
  Future<void> changeSttToOrden(Map<String, dynamic> sttFromServer) async {

    final DsRepo dsRepo = getSngOf<DsRepo>();
    await dsRepo.openBoxOrden();
    Iterable<Orden> orden = dsRepo.orden.values.where((element) => element.id == dsRepo.idRepoMainSelectCurrent);
    if(orden.isNotEmpty) {
      orden.first.est = sttFromServer['est'];
      orden.first.stt = sttFromServer['stt'];
      orden.first.save();
    }
  }

  ///
  Future<void> changeSttToPiezas(Map<String, dynamic> sttFromServer) async {
    
    final DsRepo dsRepo = getSngOf<DsRepo>();
    await dsRepo.openBoxOrden();
    Iterable<OrdenPiezas> piezas = dsRepo.ordenPzas.values.where(
      (element) => element.orden == dsRepo.idRepoMainSelectCurrent
    );
    if(piezas.isNotEmpty) {
      piezas.map((pieza) {
        pieza.est = sttFromServer['est'];
        pieza.stt = sttFromServer['stt'];
        pieza.save();
      }).toList();
    }
  }

}