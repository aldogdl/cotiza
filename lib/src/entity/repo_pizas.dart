import 'dart:convert';

import 'package:hive/hive.dart';

import '../../vars/type_ids.dart';

part 'repo_pizas.g.dart';

@HiveType(typeId: TypeIds.tiRpiezas)
class RepoPizas extends HiveObject {

  @HiveField(0)
  int id;

  @HiveField(1)
  int repo;

  @HiveField(2)
  int statusId;

  @HiveField(3)
  String statusNom;

  @HiveField(4)
  int idTmp;

  @HiveField(5)
  int cant;

  @HiveField(6)
  String pieza;

  @HiveField(7)
  String ubik;

  @HiveField(8)
  String posicion;

  @HiveField(9)
  String notas;

  @HiveField(10)
  List<String> fotos;

  @HiveField(11)
  double precioLess;

  RepoPizas({
    this.id     = 0,
    this.repo   = 0,
    this.statusId = 0,
    this.statusNom = '0',
    this.idTmp  = 0,
    this.cant   = 0,
    this.pieza  = '0',
    this.ubik   = '0',
    this.posicion = '0',
    this.notas  = '0',
    this.fotos  = const [],
    this.precioLess = 0.0
  });

  ///
  @override
  String toString() {

    return json.encode({
      'id': id,
      'repo': repo,
      'statusId': statusId,
      'statusNom': statusNom,
      'idTmp': idTmp,
      'cant': cant,
      'pieza': pieza,
      'ubik': ubik,
      'posicion': posicion,
      'notas': notas,
      'fotos': fotos,
      'precioLess': precioLess
    });
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'repo': repo,
      'statusId': statusId,
      'statusNom': statusNom,
      'idTmp': idTmp,
      'cant': cant,
      'pieza': pieza,
      'ubik': ubik,
      'posicion': posicion,
      'notas': notas,
      'fotos': fotos,
      'precioLess': precioLess
    };
  }
}