// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orden_piezas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrdenPiezasAdapter extends TypeAdapter<OrdenPiezas> {
  @override
  final int typeId = 6;

  @override
  OrdenPiezas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrdenPiezas(
      id: fields[0] as int,
      orden: fields[1] as int,
      piezaName: fields[2] as String,
      origen: fields[3] as String,
      lado: fields[4] as String,
      posicion: fields[5] as String,
      fotos: (fields[6] as List).cast<String>(),
      obs: fields[7] as String,
      est: fields[8] as String,
      stt: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrdenPiezas obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orden)
      ..writeByte(2)
      ..write(obj.piezaName)
      ..writeByte(3)
      ..write(obj.origen)
      ..writeByte(4)
      ..write(obj.lado)
      ..writeByte(5)
      ..write(obj.posicion)
      ..writeByte(6)
      ..write(obj.fotos)
      ..writeByte(7)
      ..write(obj.obs)
      ..writeByte(8)
      ..write(obj.est)
      ..writeByte(9)
      ..write(obj.stt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdenPiezasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
