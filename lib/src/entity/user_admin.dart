import 'package:hive/hive.dart';
import '../../vars/type_ids.dart';

part 'user_admin.g.dart';

@HiveType(typeId: TypeIds.tiUserAd)
class UserAdmin extends HiveObject {

  @HiveField(0)
  int id = 0;
  
  @HiveField(1)
  String username = 'Anónimo';
  
  @HiveField(2)
  String password = '';
  
  @HiveField(3)
  String role = '0';

  @HiveField(4)
  String tkServer = '0';

  @HiveField(5)
  String tkMsging = '0';

  UserAdmin({
    this.id = 0,
    this.username = 'Anónimo',
    this.password = '',
    this.role = '0',
    this.tkServer = '0',
    this.tkMsging = '0'
  });
}