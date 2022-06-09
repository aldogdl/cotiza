import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../entity/orden_piezas.dart';

class PzasToCotizarProv extends ChangeNotifier {

  ///
  bool _hasFotos = false;
  bool get hasFotos => _hasFotos;
  set hasFotos(bool has) {
    _hasFotos = has;
    notifyListeners();
  }

  ///
  void disposeTotal() {

    hasFotos = false;
    _pzaOfOrdenCurrent = {};
    removeAllKeyPiezas();
    clearPzaToSend();
  }

  ///
  Map<String, dynamic> _pzaOfOrdenCurrent = {};
  Map<String, dynamic> get piezaOfOrdenCurrent => _pzaOfOrdenCurrent;
  set pzaOfOrdenCurrent(Map<String, dynamic> pza) => _pzaOfOrdenCurrent = pza;
  void buildPzaNewOfOrden({required int idOrd}) {

    OrdenPiezas ordenPiezas = OrdenPiezas();
    ordenPiezas.id = DateTime.now().millisecondsSinceEpoch;
    ordenPiezas.orden = idOrd;
    pzaOfOrdenCurrent = ordenPiezas.toJson();
  }

  ///
  List<int> _keysPiezas = [];
  List<int> get keysPiezas => _keysPiezas;
  void removeAllKeyPiezas() => _keysPiezas = [];
  void setKeysPiezas(List<int> keys) {
    _keysPiezas = keys;
    notifyListeners();
  }
  Future<void> removeKeyPieza(int key) async {
    _keysPiezas.remove(key);
    notifyListeners();
  }


  // Usado para enviar previamente las piezas a cotizar
  List<Map<String, dynamic>> _pzasToSend = [];
  List<Map<String, dynamic>> get pzasToSend => _pzasToSend; 
  void clearPzaToSend() => _pzasToSend = [];
  void addPzaToSend(OrdenPiezas pza) {
    final inx = _pzasToSend.indexWhere((element) => element['key'] == pza.key);
    if(inx == -1) {
      _pzasToSend.add(newPzaToSend(pza));
    }else{
      if(_pzasToSend[inx]['stt'] == 'Enviada') {
        _pzasToSend[inx]['saved'] = true;
      }
    }
  }

  /// Cambiamos el status de saved al valor enviado por parametro
  Future<void> changeDataWith(int key, bool val) async {
    final inx = _pzasToSend.indexWhere((element) => element['key'] == key);
    if(inx != -1) {
      _pzasToSend[inx]['saved'] = val;
    }
    notifyListeners();
  }

  ///
  Map<String, dynamic> newPzaToSend(OrdenPiezas pza) {

    return {
      'id'     : pza.id,
      'key'    : pza.key,
      'idOrden': pza.orden,
      'idTmp'  : pza.id,
      'saved'  : (pza.est == '1' && pza.stt == '1') ? false : true,
    };
  }
}