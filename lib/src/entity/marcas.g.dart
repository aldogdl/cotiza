// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marcas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarcasAdapter extends TypeAdapter<Marcas> {
  @override
  final int typeId = 0;

  @override
  Marcas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Marcas(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      cantMods: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Marcas obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.marca)
      ..writeByte(2)
      ..write(obj.logo)
      ..writeByte(3)
      ..write(obj.cantMods);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarcasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
