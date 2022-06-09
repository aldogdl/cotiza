import 'package:hive/hive.dart';

import '../../vars/type_ids.dart';

part 'modelos.g.dart';

@HiveType(typeId: TypeIds.tiModelos)
class Modelos extends HiveObject {

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  int idMrk = 0;

  @HiveField(2)
  String modelo = '';
  
  Modelos(this.id, this.idMrk, this.modelo);
}