import 'timing_msgs.dart';

class RacerInfo {
  String registrationNumber;
  String number;
  int classNumber;
  String firstName;
  String lastName;
  String nationality;
  PracticeQualifyInfo pqPosition;
  RaceInfo racePosition;
  List<PassingInfo> passes;
  ExtraInfo extra;
  bool isExpanded;

  RacerInfo({
    this.registrationNumber = "",
    this.number = "",
    this.classNumber = 0,
    this.firstName = "",
    this.lastName = "",
    this.nationality = "",
    this.isExpanded = false,
    PracticeQualifyInfo? pqPosition,
    RaceInfo? racePosition,
    List<PassingInfo>? passes,
    ExtraInfo? extra,
  })  : pqPosition = pqPosition ?? PracticeQualifyInfo(),
        racePosition = racePosition ?? RaceInfo(),
        passes = passes ?? [],
        extra = extra ?? ExtraInfo();

  @override
  String toString() {
    return 'RacerInfo(registrationNumber: $registrationNumber, number: $number, classNumber: $classNumber, firstName: $firstName, lastName: $lastName, nationality: $nationality, pqPosition: $pqPosition, racePosition: $racePosition, passes: $passes)';
  }

  void setPqPos(PracticeQualifyInfo pqInfo) {
    pqPosition = pqInfo;
  }

  void setRacePos(RaceInfo raceInfo) {
    racePosition = raceInfo;
  }

  void addPass(PassingInfo pass) {
    passes.add(pass);
  }

  factory RacerInfo.fromJson(Map<String, dynamic> json) {
    return RacerInfo(
      registrationNumber: json['registrationNumber'] ?? "",
      number: json['number'] ?? "",
      classNumber: json['classNumber'] ?? 0,
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      nationality: json['nationality'] ?? "",
      pqPosition: PracticeQualifyInfo.fromJson(json['pqPosition'] ?? {}),
      racePosition: RaceInfo.fromJson(json['racePosition'] ?? {}),
      passes: (json['passes'] as List<dynamic>? ?? [])
          .map((pass) => PassingInfo.fromJson(pass))
          .where((pass) => !(pass.lapTime.minutes == 0 && pass.lapTime.seconds == 0))
          .toList(),
    );
  }
}
