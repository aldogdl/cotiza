import 'package:hive/hive.dart';
import 'package:autoparnet_cotiza/vars/type_ids.dart';

part 'repo_info.g.dart';

@HiveType(typeId: TypeIds.tiRinfo)
class RepoInfo extends HiveObject {

  @HiveField(0)
  int? id;

  @HiveField(1)
  int? idRepo;

  @HiveField(2)
  int? idPza;

  @HiveField(3)
  int? statusId;

  @HiveField(4)
  String? statusNom;

  @HiveField(5)
  double? precio;

  RepoInfo({
    this.id = 0,
    this.idRepo = 0,
    this.idPza = 0,
    this.statusId = 0,
    this.statusNom = '0',
    this.precio = 0.0,
  });
}