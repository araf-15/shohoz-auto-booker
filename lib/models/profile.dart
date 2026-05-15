import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class PassengerInfo extends HiveObject {
  @HiveField(0)
  String firstName;

  @HiveField(1)
  String lastName;

  @HiveField(2)
  String gender; // 'male' or 'female'

  PassengerInfo({
    required this.firstName,
    required this.lastName,
    this.gender = 'male',
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
      };
}

@HiveType(typeId: 1)
class BookingProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String from;

  @HiveField(3)
  String to;

  @HiveField(4)
  String busType; // 'any', 'ac', 'nonac'

  @HiveField(5)
  String preferredOperator;

  @HiveField(6)
  int ticketCount;

  @HiveField(7)
  List<String> seatPreferences; // ['window', 'front', 'aisle']

  @HiveField(8)
  bool avoidBackSeats;

  @HiveField(9)
  List<String> preferredDepartureTimes; // ['06:00', '07:00']

  @HiveField(10)
  List<PassengerInfo> passengers;

  @HiveField(11)
  bool autoCheckEnabled;

  @HiveField(12)
  List<String> checkTimes; // ['08:00', '12:00']

  @HiveField(13)
  int daysInAdvance;

  @HiveField(14)
  bool isActive;

  BookingProfile({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    this.busType = 'any',
    this.preferredOperator = '',
    this.ticketCount = 1,
    this.seatPreferences = const ['window', 'front'],
    this.avoidBackSeats = true,
    this.preferredDepartureTimes = const [],
    this.passengers = const [],
    this.autoCheckEnabled = false,
    this.checkTimes = const [],
    this.daysInAdvance = 1,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'from': from,
        'to': to,
        'busType': busType,
        'preferredOperator': preferredOperator,
        'ticketCount': ticketCount,
        'seatPreferences': seatPreferences,
        'avoidBackSeats': avoidBackSeats,
        'preferredDepartureTimes': preferredDepartureTimes,
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'autoCheckEnabled': autoCheckEnabled,
        'checkTimes': checkTimes,
        'daysInAdvance': daysInAdvance,
      };
}
