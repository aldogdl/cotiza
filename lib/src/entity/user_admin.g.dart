// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_admin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdminAdapter extends TypeAdapter<UserAdmin> {
  @override
  final int typeId = 2;

  @override
  UserAdmin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAdmin(
      id: fields[0] as int,
      username: fields[1] as String,
      password: fields[2] as String,
      role: fields[3] as String,
      tkServer: fields[4] as String,
      tkMsging: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserAdmin obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.tkServer)
      ..writeByte(5)
      ..write(obj.tkMsging);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdminAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
