import 'package:hive/hive.dart';

import '../../vars/type_ids.dart';

part 'marcas.g.dart';

@HiveType(typeId: TypeIds.tiMarcas)
class Marcas extends HiveObject {

  //flutter packages pub run build_runner build --delete-conflicting-outputs

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  String marca = '';
  
  @HiveField(2)
  String logo = '';

  @HiveField(3)
  int cantMods = 0;
  
  Marcas(this.id, this.marca, this.logo, {this.cantMods = 0});
}