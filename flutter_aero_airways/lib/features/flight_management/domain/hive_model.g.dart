// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteFlightAdapter extends TypeAdapter<FavoriteFlight> {
  @override
  final int typeId = 0;

  @override
  FavoriteFlight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteFlight(
      id: fields[0] as String,
      airline: fields[1] as String,
      flightNumber: fields[2] as String,
      departureAirport: fields[3] as String,
      arrivalAirport: fields[4] as String,
      departureTime: fields[5] as String,
      arrivalTime: fields[6] as String,
      status: fields[7] as String,
      savedAt: fields[8] as DateTime,
      flightDate: fields[9] as String,
      departureIata: fields[10] as String,
      arrivalIata: fields[11] as String,
      departureTerminal: fields[12] as String?,
      departureGate: fields[13] as String?,
      arrivalTerminal: fields[14] as String?,
      arrivalGate: fields[15] as String?,
      departureDelay: fields[16] as int?,
      arrivalDelay: fields[17] as int?,
      rawData: (fields[18] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteFlight obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.airline)
      ..writeByte(2)
      ..write(obj.flightNumber)
      ..writeByte(3)
      ..write(obj.departureAirport)
      ..writeByte(4)
      ..write(obj.arrivalAirport)
      ..writeByte(5)
      ..write(obj.departureTime)
      ..writeByte(6)
      ..write(obj.arrivalTime)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.savedAt)
      ..writeByte(9)
      ..write(obj.flightDate)
      ..writeByte(10)
      ..write(obj.departureIata)
      ..writeByte(11)
      ..write(obj.arrivalIata)
      ..writeByte(12)
      ..write(obj.departureTerminal)
      ..writeByte(13)
      ..write(obj.departureGate)
      ..writeByte(14)
      ..write(obj.arrivalTerminal)
      ..writeByte(15)
      ..write(obj.arrivalGate)
      ..writeByte(16)
      ..write(obj.departureDelay)
      ..writeByte(17)
      ..write(obj.arrivalDelay)
      ..writeByte(18)
      ..write(obj.rawData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteFlightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
