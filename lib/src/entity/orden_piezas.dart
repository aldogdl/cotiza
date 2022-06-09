import 'package:hive/hive.dart';

import 'package:autoparnet_cotiza/vars/type_ids.dart';

part 'orden_piezas.g.dart';

@HiveType(typeId: TypeIds.tiOrdPzas)
class OrdenPiezas extends HiveObject {
  
  @HiveField(0)
  int id = 0;

  @HiveField(1)
  int orden = 0;
  
  @HiveField(2)
  String piezaName = '';

  @HiveField(3)
  String origen = '';

  @HiveField(4)
  String lado = '';

  @HiveField(5)
  String posicion = '';

  @HiveField(6)
  List<String> fotos = [];

  @HiveField(7)
  String obs = '';

  @HiveField(8)
  String est = '';

  @HiveField(9)
  String stt = '';

  OrdenPiezas({
    this.id = 0,
    this.orden = 0,
    this.piezaName = '',
    this.origen = '',
    this.lado = '',
    this.posicion = '',
    this.fotos = const [],
    this.obs = '',
    this.est = '1',
    this.stt = '1',
  });

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'orden': orden,
      'piezaName': piezaName,
      'origen': origen,
      'lado': lado,
      'posicion': posicion,
      'fotos': fotos,
      'obs': obs,
      'est': est,
      'stt': stt
    };
  }

  ///
  void fromJson(Map<String, dynamic> json) {

    id       = json['id'];
    orden    = json['orden'];
    piezaName= json['piezaName'];
    origen   = json['origen'];
    lado     = json['lado'];
    posicion = json['posicion'];
    obs      = json['obs'];
    est      = json['est'];
    stt      = json['stt'];
    if(json['fotos'].isNotEmpty) {
      fotos = List<String>.from(json['fotos']);
    }
  }

  ///
  void fromServerMap(Map<String, dynamic> json) {

    id       = json['p_id'];
    orden    = json['o_id'];
    piezaName= json['p_piezaName'];
    origen   = json['p_origen'];
    lado     = json['p_lado'];
    posicion = json['p_posicion'];
    obs      = json['p_obs'];
    est      = json['p_est'];
    stt      = json['p_stt'];
    
    if(json['p_fotos'].isNotEmpty) {
      fotos = List<String>.from(json['p_fotos']);
    }
  }
}