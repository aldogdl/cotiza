import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/get_uris.dart';
import '../services/my_http.dart';

class UserAdmRepository {

  MyHttp http = MyHttp();

  Map<String, dynamic> result = {'abort': false, 'msg': 'ok', 'body': ''};

  ///
  void cleanResult() { 
    result = {'abort': false, 'msg':'ok', 'body':[]};
    http.cleanResult();
  }

  ///
  Future<void> checkLogin(Map<String, dynamic> data) async {

    String uri = GetUris.getUriBy('login_check_admin');
    await http.postD(uri, data, hasToken: false);
    result = http.result;
    return;
  }

  ///
  Future<void> getUsersByCampo({
    required String campo,
    required String valor,
    required String tokenServer,
  }) async {

    String uri = GetUris.getUriBy('get_user_by_campo');
    uri = '$uri?campo=$campo&valor=$valor';
    http.tokenServer = tokenServer;
    await http.getD(uri);
    result = http.result;
    return;
  }

  ///
  Future<void> isTokenCaducado() async {

    String uri = GetUris.getUriBy('is_tokenapz_caducado');
    await http.getD(uri);
    result = http.result;
    return;
  }

  ///
  Future<void> enviandoTokenPush(String token, int idUser) async {

    String uri = GetUris.getUriBy('set_token_msg_user');
    Map<String, dynamic> data = {
      'user': idUser,
      'token' : token,
      'toSafe': (kIsWeb) ? 'web' : 'app'
    };
    await http.postD(uri, data);
    result = http.result;
    return;
  }

}