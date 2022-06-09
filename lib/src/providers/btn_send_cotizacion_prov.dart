import 'package:flutter/foundation.dart' show ChangeNotifier;

class BtnSendCotizacionProv extends ChangeNotifier {
  
  bool _activeBtnSend = false;
  bool get activeBtnSend => _activeBtnSend;
  set activeBtnSend(bool newVal) {
    _activeBtnSend = newVal;
    notifyListeners();
  }
  
  bool _activeLoaderSend = false;
  bool get activLoaderSend => _activeLoaderSend;
  Future<void> setActiveLoaderSend(bool newVal) async {
    _activeLoaderSend = newVal;
    notifyListeners();
  }
}