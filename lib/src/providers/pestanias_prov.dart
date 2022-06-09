import 'package:flutter/foundation.dart' show ChangeNotifier;

class PestaniasProv extends ChangeNotifier {

  // Cotizar, Cotizaciones, changePage
  String _pestaniaSelect = 'Cotizaciones';
  String get pestaniaSelect => _pestaniaSelect;
  set pestaniaSelect(String newVal) {
    _pestaniaSelect = newVal;
    notifyListeners();
  }
}