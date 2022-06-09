import 'package:hive/hive.dart';

import '../../vars/type_ids.dart';

part 'repo_main.g.dart';

@HiveType(typeId: TypeIds.tiRmain)
class RepoMain extends HiveObject {

  @HiveField(0)
  int id;
  
  @HiveField(1)
  int autoId;

  @HiveField(2)
  int adminId;

  @HiveField(3)
  int statusId;

  @HiveField(4)
  String statusNom;

  @HiveField(5)
  String regType;

  @HiveField(6)
  DateTime createdAt;

  RepoMain(
    this.id, this.autoId, this.createdAt,
    {
      this.adminId = 0, this.statusId = 1, this.statusNom = 'INCOMPLETA',  this.regType = 'cot'
    }
  );
}