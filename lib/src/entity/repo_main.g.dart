// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepoMainAdapter extends TypeAdapter<RepoMain> {
  @override
  final int typeId = 8;

  @override
  RepoMain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepoMain(
      fields[0] as int,
      fields[1] as int,
      fields[6] as DateTime,
      adminId: fields[2] as int,
      statusId: fields[3] as int,
      statusNom: fields[4] as String,
      regType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RepoMain obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.autoId)
      ..writeByte(2)
      ..write(obj.adminId)
      ..writeByte(3)
      ..write(obj.statusId)
      ..writeByte(4)
      ..write(obj.statusNom)
      ..writeByte(5)
      ..write(obj.regType)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoMainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
