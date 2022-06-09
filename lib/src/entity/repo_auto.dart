import 'package:hive/hive.dart';

import '../../vars/type_ids.dart';

part 'repo_auto.g.dart';

@HiveType(typeId: TypeIds.tiRauto)
class RepoAuto extends HiveObject {

  @HiveField(0)
  int id;

  @HiveField(1)
  int idMrk;

  @HiveField(2)
  int idMdl;

  @HiveField(3)
  int anio;

  @HiveField(4)
  bool isNac;

  RepoAuto({
    this.id = 0, this.idMrk = 0, this.idMdl = 0, this.anio = 0, this.isNac = true
  });

  ///
  void fromMap(Map<String, dynamic> data) {

    id    = data['auto_id'];
    idMrk = data['id_marca'];
    idMdl = data['id_modelo'];
    anio  = data['anio'];
    isNac = data['is_nacional'];
  }
}