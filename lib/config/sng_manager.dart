import 'package:get_it/get_it.dart';

import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/src/pages/home/data_shared/ds_repo.dart';
import 'package:autoparnet_cotiza/src/services/fbm_google.dart';
import 'package:autoparnet_cotiza/src/widgets/get_fotos/singleton/picker_pictures.dart';

GetIt getSngOf = GetIt.instance;

void sngManager() {

  getSngOf.registerLazySingleton(() => Globals());
  getSngOf.registerLazySingleton(() => RefCotiz());
  getSngOf.registerLazySingleton(() => DsRepo());
  getSngOf.registerLazySingleton(() => PickerPictures());
  getSngOf.registerLazySingleton(() => FBMGoogle());

}