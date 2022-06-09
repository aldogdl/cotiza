// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piezas_reg.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PiezasRegAdapter extends TypeAdapter<PiezasReg> {
  @override
  final int typeId = 7;

  @override
  PiezasReg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PiezasReg()
      ..pieza = fields[0] as String
      ..lado = fields[1] as String
      ..posicion = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, PiezasReg obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pieza)
      ..writeByte(1)
      ..write(obj.lado)
      ..writeByte(2)
      ..write(obj.posicion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PiezasRegAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
