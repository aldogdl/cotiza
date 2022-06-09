import 'package:autoparnet_cotiza/vars/type_ids.dart';
import 'package:hive/hive.dart';

part 'last_data_in.g.dart';

/// Clase utilizada para almacenar la ultima ves que el usuario ingreso a la app
/// con el objetivo de hacer login silencioso y calcular si es necesario refrescar
/// token o no, esto por medio del campo fecha.
@HiveType(typeId: TypeIds.tiLdtIn)
class LastDataIn extends HiveObject {

  @HiveField(0)
  String lastPath = '';

  @HiveField(1)
  String fecha = '';
  
  LastDataIn({
    required this.fecha, this.lastPath = ''
  });
}