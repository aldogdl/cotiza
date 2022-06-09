// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_pizas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepoPizasAdapter extends TypeAdapter<RepoPizas> {
  @override
  final int typeId = 9;

  @override
  RepoPizas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepoPizas(
      id: fields[0] as int,
      repo: fields[1] as int,
      statusId: fields[2] as int,
      statusNom: fields[3] as String,
      idTmp: fields[4] as int,
      cant: fields[5] as int,
      pieza: fields[6] as String,
      ubik: fields[7] as String,
      posicion: fields[8] as String,
      notas: fields[9] as String,
      fotos: (fields[10] as List).cast<String>(),
      precioLess: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, RepoPizas obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.repo)
      ..writeByte(2)
      ..write(obj.statusId)
      ..writeByte(3)
      ..write(obj.statusNom)
      ..writeByte(4)
      ..write(obj.idTmp)
      ..writeByte(5)
      ..write(obj.cant)
      ..writeByte(6)
      ..write(obj.pieza)
      ..writeByte(7)
      ..write(obj.ubik)
      ..writeByte(8)
      ..write(obj.posicion)
      ..writeByte(9)
      ..write(obj.notas)
      ..writeByte(10)
      ..write(obj.fotos)
      ..writeByte(11)
      ..write(obj.precioLess);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoPizasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
