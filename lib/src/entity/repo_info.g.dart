// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepoInfoAdapter extends TypeAdapter<RepoInfo> {
  @override
  final int typeId = 11;

  @override
  RepoInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepoInfo(
      id: fields[0] as int?,
      idRepo: fields[1] as int?,
      idPza: fields[2] as int?,
      statusId: fields[3] as int?,
      statusNom: fields[4] as String?,
      precio: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, RepoInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idRepo)
      ..writeByte(2)
      ..write(obj.idPza)
      ..writeByte(3)
      ..write(obj.statusId)
      ..writeByte(4)
      ..write(obj.statusNom)
      ..writeByte(5)
      ..write(obj.precio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
