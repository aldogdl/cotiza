// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelos.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelosAdapter extends TypeAdapter<Modelos> {
  @override
  final int typeId = 1;

  @override
  Modelos read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Modelos(
      fields[0] as int,
      fields[1] as int,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Modelos obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idMrk)
      ..writeByte(2)
      ..write(obj.modelo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
