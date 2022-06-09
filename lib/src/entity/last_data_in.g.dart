// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_data_in.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LastDataInAdapter extends TypeAdapter<LastDataIn> {
  @override
  final int typeId = 12;

  @override
  LastDataIn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LastDataIn(
      fecha: fields[1] as String,
      lastPath: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LastDataIn obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lastPath)
      ..writeByte(1)
      ..write(obj.fecha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastDataInAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
