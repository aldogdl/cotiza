import 'package:hive/hive.dart';

import '../../vars/type_ids.dart';

part 'orden.g.dart';

@HiveType(typeId: TypeIds.tiOrden)
class Orden extends HiveObject {

  @HiveField(0)
  int id = 0;
  @HiveField(1)
  int own = 0;
  @HiveField(2)
  int marca = 0;
  @HiveField(3)
  int modelo = 0;
  @HiveField(4)
  int anio = 0;
  @HiveField(5)
  bool isNac = true;
  @HiveField(6)
  DateTime createdAt = DateTime.now();
  @HiveField(7)
  int avo = 0;
  @HiveField(8)
  String est = '1';
  @HiveField(9)
  String stt = '1';

  ///
  void fromMap(Map<String, dynamic> data) {

    id    = data['id'];
    own   = data['own'];
    marca = data['id_marca'];
    modelo= data['id_modelo'];
    anio  = data['anio'];
    isNac = data['is_nacional'];
    est   = data['est'];
    stt   = data['stt'];
    avo   = (data.containsKey('avo')) ? data['avo'] : 0;
    createdAt= DateTime.parse(data['created_at']['date']);
  }

  ///
  Map<String, dynamic> toServer() {
    return {
      'id': id,
      'own': own,
      'id_marca': marca,
      'id_modelo': modelo,
      'anio': anio,
      'est': est,
      'stt': stt,
      'is_nacional': isNac
    };
  }

  ///
  void fromServerMap(Map<String, dynamic> data) {

    id    = data['o_id'];
    own   = data['u_id'];
    marca = data['mk_id'];
    modelo= data['md_id'];
    anio  = data['o_anio'];
    isNac = data['o_isNac'];
    est   = data['o_est'];
    stt   = data['o_stt'];
    avo   = (data.containsKey('a_id')) ? data['a_id']??0 : 0;
    createdAt= DateTime.parse(data['o_createdAt']['date']);
  }
}