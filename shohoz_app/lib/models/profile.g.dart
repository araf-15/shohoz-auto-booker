// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'profile.dart';

class PassengerInfoAdapter extends TypeAdapter<PassengerInfo> {
  @override
  final int typeId = 0;

  @override
  PassengerInfo read(BinaryReader reader) {
    return PassengerInfo(
      firstName: reader.read() as String,
      lastName: reader.read() as String,
      gender: reader.read() as String,
    );
  }

  @override
  void write(BinaryWriter writer, PassengerInfo obj) {
    writer.write(obj.firstName);
    writer.write(obj.lastName);
    writer.write(obj.gender);
  }
}

class BookingProfileAdapter extends TypeAdapter<BookingProfile> {
  @override
  final int typeId = 1;

  @override
  BookingProfile read(BinaryReader reader) {
    return BookingProfile(
      id: reader.read() as String,
      name: reader.read() as String,
      from: reader.read() as String,
      to: reader.read() as String,
      busType: reader.read() as String,
      preferredOperator: reader.read() as String,
      ticketCount: reader.read() as int,
      seatPreferences: (reader.read() as List).cast<String>(),
      avoidBackSeats: reader.read() as bool,
      preferredDepartureTimes: (reader.read() as List).cast<String>(),
      passengers: (reader.read() as List).cast<PassengerInfo>(),
      autoCheckEnabled: reader.read() as bool,
      checkTimes: (reader.read() as List).cast<String>(),
      daysInAdvance: reader.read() as int,
      isActive: reader.read() as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BookingProfile obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.from);
    writer.write(obj.to);
    writer.write(obj.busType);
    writer.write(obj.preferredOperator);
    writer.write(obj.ticketCount);
    writer.write(obj.seatPreferences);
    writer.write(obj.avoidBackSeats);
    writer.write(obj.preferredDepartureTimes);
    writer.write(obj.passengers);
    writer.write(obj.autoCheckEnabled);
    writer.write(obj.checkTimes);
    writer.write(obj.daysInAdvance);
    writer.write(obj.isActive);
  }
}
