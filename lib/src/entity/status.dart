import 'package:hive/hive.dart';

import 'package:autoparnet_cotiza/vars/type_ids.dart';
part 'status.g.dart';

@HiveType(typeId: TypeIds.tiStatus)
class Status extends HiveObject {

  @HiveField(0)
  Map<String, dynamic> est = {};
  @HiveField(1)
  Map<String, dynamic> stt = {};
  @HiveField(2)
  Map<String, dynamic> ext = {};

  ///
  Map<String, dynamic> toJson() {

    return {
      'est': est,
      'stt': stt,
      'ext': ext,
    };
  }
}