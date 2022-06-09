// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_auto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepoAutoAdapter extends TypeAdapter<RepoAuto> {
  @override
  final int typeId = 4;

  @override
  RepoAuto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepoAuto(
      id: fields[0] as int,
      idMrk: fields[1] as int,
      idMdl: fields[2] as int,
      anio: fields[3] as int,
      isNac: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RepoAuto obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idMrk)
      ..writeByte(2)
      ..write(obj.idMdl)
      ..writeByte(3)
      ..write(obj.anio)
      ..writeByte(4)
      ..write(obj.isNac);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoAutoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
