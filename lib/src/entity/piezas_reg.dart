import 'package:autoparnet_cotiza/vars/type_ids.dart';
import 'package:hive/hive.dart';

part 'piezas_reg.g.dart';

@HiveType(typeId: TypeIds.tiPzReg)
class PiezasReg extends HiveObject {

  @HiveField(0)
  String pieza = '';
  @HiveField(1)
  String lado = '';
  @HiveField(2)
  String posicion = '';

  ///
  Map<String, dynamic> toJsonToFrm() {

    return {
      'key'     : key,
      'pieza'   : pieza,
      'lado'    : lado,
      'posicion': posicion,
    };
  }
}