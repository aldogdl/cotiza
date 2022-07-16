
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

class GetUris{

  static Globals globals = getSngOf<Globals>();
  
  static const String _env  = 'prod';
  static const String _baseD= 'http://192.168.1.74/autoparnet/public_html';
  static const String _baseP= 'https://autoparnet.com';
  static const String _pfxP = 'data-shared';
  // static const String _pfxP = 'api/firewalls/publicas';

  static const String _pfapG = 'api/firewalls/autoparnet/repo-get';
  static const String _pfapP = 'api/firewalls/autoparnet/repo-post';
  static const String _pfapS = 'api/firewalls/autoparnet/pushes';

  ///
  static String get base => (_env == 'dev') ? _baseD : _baseP;
  static String get baseSelf => (_env == 'dev') ? _baseD : _baseP;

  ///
  static String getUriBy(String namePath) {

    Map<String, dynamic>? paths = _getRutasApis();
    String ruta = '$base/${paths[namePath]['rut']}';
    paths = null;
    return ruta;
  }

  ///
  static String getUriLogoMarcas() => '$base/mrks_logos';

  ///
  static String getUriBgLogin(String file) {

    if(globals.isWeb) {
      return '$base/images/login_app/$file';
    }
    return '$base/images/login_app/$file';
  }

  ///
  static String getUriFtoRespuesta(int idRepoMain, int idInfo, String file) {

    String prefixDev = (_env == 'dev') ? '/web/pictures/cotizadas' : '/pictures/cotizadas';
    prefixDev = '$baseSelf$prefixDev/';
    return '$prefixDev$idRepoMain/$idInfo/$file';
  }

  ///
  static String getUriFotoPzaBeforeCot(String filename) => '$base/to_orden_tmp/$filename';

  ///
  static String getUriFotoPza(String sufix) {

    String prefixDev = (_env == 'dev') ? '/web' : baseSelf;
    return '$prefixDev/pictures/to_cotizar/$sufix';
  }

  ///
  static Map<String, dynamic> _getRutasApis() {

    const pfx = <String, dynamic>{'pub' : 'cotiza/', 'api' : 'api/cotiza/'};

    return {
      'login_check_admin'   : {'rut' : 'secure-api-check'},
      'get_all_marcas'      : {'rut' : '${pfx['pub']}get-all-marcas/'},
      'get_status_ordenes'  : {'rut' : '${pfx['pub']}get-status-ordenes/'},
      'get_modelos_by_marca': {'rut' : '${pfx['pub']}get-modelos-by-marca/'},
      'get_user_by_campo'   : {'rut' : '${pfx['api']}get-user-by-campo/'},
      'set_token_msg_user'  : {'rut' : '${pfx['api']}set-token-messaging-by-id-user/'},
      'is_tokenapz_caducado': {'rut' : '${pfx['api']}is-tokenapz-caducado/'},
      'set_orden'           : {'rut' : '${pfx['api']}set-orden/'},
      'set_pieza'           : {'rut' : '${pfx['api']}set-pieza/'},
      'del_pieza'           : {'rut' : '${pfx['api']}del-pieza/'},
      'enviar_orden'        : {'rut' : '${pfx['api']}enviar-orden/'},
      'ordenes_by_seccion'  : {'rut' : '${pfx['api']}get-ordenes-by-own-and-seccion/'},
      'pzas_by_lstOrdenes'  : {'rut' : '${pfx['api']}get-piezas-by-lst-ordenes/'},
      'upload_img'          : {'rut' : '${pfx['api']}upload-img/'},
      'delImg_of_orden_tmp' : {'rut' : '${pfx['api']}del-img-of-orden-tmp/'},
      'setFileShare_device' : {'rut' : '${pfx['api']}set-file-share-img-device/'},
      'checkShare_imgDevice': {'rut' : '${pfx['api']}check-share-img-device/'},
      'openShare_imgDevice' : {'rut' : '${pfx['pub']}open-share-img-device/'},
      'finShare_imgDevice'  : {'rut' : '${pfx['api']}fin-share-img-device/'},
      'delShare_imgDevice'  : {'rut' : '${pfx['api']}del-share-img-device/'},
      'delete_orden'        : {'rut' : '${pfx['api']}delete-orden/'},


      'save_foto_to'        : {'pfxP': _pfapP, 'rut' : 'save-foto-to'},
      'save_foto_to_share'  : {'pfxP': _pfapP, 'rut' : 'save-foto-to-share'},
      'save_foto_to_share_for_respctz'  : {'pfxP': _pfapP, 'rut' : 'save-foto-to-share-for-respctz'},
      'get_fotos_shared_from_app_to_web'  : {'pfxP': _pfapG, 'rut' : 'get-fotos-shared-from-app-to-web'},
      'get_respuestas_xcot'  : {'pfxP': _pfapG, 'rut' : 'get-respuestas-xcot'},
      'delete_fotos_shared'  : {'pfxP': _pfapG, 'rut' : 'delete-fotos-shared'},
      'save_repo_piezas_for_cot'  : {'pfxP': _pfapP, 'rut' : 'save-repo-piezas-for-cot'},
      'save_repo_pedido'  : {'pfxP': _pfapP, 'rut' : 'save-repo-pedido'},
      'get_repo_autos_by_ids': {'pfxP' : _pfapG, 'rut' : 'get-repo-autos-by-ids'},
      'get_modelos_by_ids_marca': {'pfxP': _pfxP, 'rut' : 'get-modelos-by-ids-marca'},
      'send_push_nueva_cotizacion': {'pfxP': _pfapS, 'rut' : 'send-push-nueva-cotizacion'},
      'send_push_leida': {'pfxP': _pfapS, 'rut' : 'send-push-leida'},
      'send_push_pedido': {'pfxP': _pfapS, 'rut' : 'send-push-pedido'},
      'send_push_test_from_taller': {'pfxP': _pfapS, 'rut' : 'send-push-test-from-taller'},
    };
  }


}
