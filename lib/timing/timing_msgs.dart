/* Flags Data Structure */

class Heartbeat {
  // Flag $F
  int lapsToGo;
  String timeToGo;
  String timeOfDay;
  String raceTime;
  String flagStatus;

  Heartbeat({
    this.lapsToGo = 0,
    this.timeToGo = "",
    this.timeOfDay = "",
    this.raceTime = "",
    this.flagStatus = "",
  });

  factory Heartbeat.fromJson(Map<String, dynamic> json) {
    return Heartbeat(
      lapsToGo: json['lapsToGo'] ?? 0,
      timeToGo: json['timeToGo'] ?? "",
      timeOfDay: json['time'] ?? "",
      raceTime: json['raceTime'] ?? "",
      flagStatus: json['flagStatus'] ?? "",
    );
  }
}

class CompInfo {
  // Flag $COMP
  String regNumber;
  String number;
  int classNumber;
  String firstName;
  String lastName;
  String nationality;

  CompInfo({
    this.regNumber = "",
    this.number = "",
    this.classNumber = 0,
    this.firstName = "",
    this.lastName = "",
    this.nationality = "",
  });

  factory CompInfo.fromJson(Map<String, dynamic> json) {
    return CompInfo(
      regNumber: json['registrationNumber'] ?? "",
      number: json['number'] ?? "",
      classNumber: json['classNumber'] ?? 0,
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      nationality: json['nationality'] ?? "",
    );
  }
}

class RaceInfo {
  // Flag $G
  int position;
  String regNumber;
  int laps;
  Time totalTime;

  RaceInfo({
    this.position = 0,
    this.regNumber = "",
    this.laps = 0,
    Time? totalTime,
  }) : totalTime = totalTime ?? Time();

  @override
  String toString() {
    return "position: $position, regNumber: $regNumber, laps: $laps, time: $totalTime ";
  }

  factory RaceInfo.fromJson(Map<String, dynamic> json) {
    int parsedMinutes = 0;
    double parsedSeconds = 0.0;
    double parsedMilliseconds = 0.0;
    if (json['totalTime'].contains('ms')) {
      parsedMinutes = 0;
      parsedSeconds = 0;
      parsedMilliseconds = double.tryParse(json['totalTime'].split('ms')[0]) ?? 0.0;
    } else if (json['totalTime'].contains('m')) {
      parsedMinutes = int.tryParse(json['totalTime'].split('m')[0]) ?? 0;
      parsedSeconds =
          double.tryParse(json['totalTime'].split('m')[1].split('s')[0]) ?? 0.0;
      parsedMilliseconds = 0;
    } else {
      parsedMinutes = 0;
      parsedSeconds = double.tryParse(json['totalTime'].split('s')[0]) ?? 0.0;
      parsedMilliseconds = 0;
    }

    return RaceInfo(
      position: json['position'],
      regNumber: json['registrationNumber'] ?? "",
      laps: json['laps'] ?? 0,
      totalTime: Time(
          minutes: parsedMinutes,
          seconds: parsedSeconds,
          milliseconds: parsedMilliseconds),
    );
  }
}

class RunInfo {
  // Flag $B
  int uniqueNumber;
  String description;

  RunInfo({
    this.uniqueNumber = 0,
    this.description = "",
  });

  factory RunInfo.fromJson(Map<String, dynamic> json) {
    return RunInfo(
      uniqueNumber: json['number'] ?? 0,
      description: json['description'] ?? "",
    );
  }
}

class ClassInfo {
  // Flag $C
  int uniqueNumber;
  String description;

  ClassInfo({
    this.uniqueNumber = 0,
    this.description = "",
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      uniqueNumber: json['number'] ?? 0,
      description: json['description'] ?? "",
    );
  }
}

class PracticeQualifyInfo {
  // Flag $H
  int position;
  int bestLap;
  Time bestLapTime;
  String regNumber;

  PracticeQualifyInfo({
    this.position = 0,
    this.bestLap = 0,
    Time? bestLapTime,
    this.regNumber = "",
  }) : bestLapTime = bestLapTime ?? Time();

  factory PracticeQualifyInfo.fromJson(Map<String, dynamic> json) {
  int parsedMinutes = 0;
  double parsedSeconds = 0.0;
  double parsedMilliseconds = 0.0;

  String bestLaptime = json['bestLaptime'] ?? '0s';  // Default to '0s' if missing

  if (bestLaptime.contains('ms')) {
    parsedMilliseconds = double.tryParse(bestLaptime.split('ms')[0]) ?? 0.0;
  } else if (bestLaptime.contains('m')) {
    parsedMinutes = int.tryParse(bestLaptime.split('m')[0]) ?? 0;
    parsedSeconds = double.tryParse(bestLaptime.split('m')[1].split('s')[0]) ?? 0.0;
  } else if (bestLaptime.contains('s')) {
    parsedSeconds = double.tryParse(bestLaptime.split('s')[0]) ?? 0.0;
  }

  return PracticeQualifyInfo(
    position: json['position'] ?? 0,
    bestLap: json['bestLap'] ?? 0,
    bestLapTime: Time(
      minutes: parsedMinutes,
      seconds: parsedSeconds,
      milliseconds: parsedMilliseconds,
    ),
    regNumber: json['registrationNumber'] ?? "",
  );
}

}

class PassingInfo {
  // Flag $J
  String regNumber;
  Time lapTime;
  String totalTime;

  PassingInfo({
    this.regNumber = "",
    Time? lapTime,
    this.totalTime = "",
  }) : lapTime = lapTime ?? Time();

  @override
  String toString() {
    return "${lapTime}";
  }

  factory PassingInfo.fromJson(Map<String, dynamic> json) {
    int parsedLapTimeMinutes = 0;
    double parsedLapTimeSeconds = 0.0;
    if (json['lapTime'].contains('m')) {
      parsedLapTimeMinutes = int.tryParse(json['lapTime'].split('m')[0]) ?? 0;
      parsedLapTimeSeconds =
          double.tryParse(json['lapTime'].split('m')[1].split('s')[0]) ?? 0.0;
    } else {
      parsedLapTimeMinutes = 0;
      parsedLapTimeSeconds = double.tryParse(json['lapTime'].split('s')[0]) ?? 0.0;
    }
    return PassingInfo(
      regNumber: json['registrationNumber'] ?? "",
      lapTime:
          Time(minutes: parsedLapTimeMinutes, seconds: parsedLapTimeSeconds),
      totalTime: json["totalTime"] ?? "",
    );
  }
}

class ExtraInfo {
  int previousPosition;
  Time gapToNext;
  Time gapToFirst;
  Time bestLapTime;
  Time previousLapTime;

  ExtraInfo({
    this.previousPosition = 0,
    Time? gapToNext,
    Time? gapToFirst,
    Time? bestLapTime,
    Time? previousLapTime,
  })  : gapToNext = gapToNext ?? Time(),
        gapToFirst = gapToFirst ?? Time(),
        bestLapTime = bestLapTime ?? Time(),
        previousLapTime = previousLapTime ?? Time();
}

class Time {
  int minutes;
  double seconds;
  double milliseconds;

  Time({
    this.minutes = 0,
    this.seconds = 0,
    this.milliseconds = 0,
  }) {
    seconds = double.tryParse(seconds.toStringAsFixed(2)) ?? 0.0;
  }

  @override
  String toString() {
    if (minutes != 0) {
      if (seconds < 10) {
        return '$minutes:0$seconds';
      } else {
        return '$minutes:$seconds';
      }
    } else {
      return '$seconds';
    }
  }

  double toDouble() {
    return 60 * minutes + seconds + milliseconds / 1000;
  }

  Time subtract(Time other) {
    double resultSeconds = toDouble() - other.toDouble();
    int resultMinutes = (resultSeconds ~/ 60).toInt();
    double resultRemainingSeconds = resultSeconds % 60;
    
    if (resultSeconds < 0) {
        return Time(minutes: 0, seconds: 0, milliseconds: 0);
    }
    resultRemainingSeconds =
        double.tryParse(resultRemainingSeconds.toStringAsFixed(2)) ?? 0.0;
    return Time(
      minutes: resultMinutes,
      seconds: resultRemainingSeconds,
    );
  }

  Time add(Time other) {
    double resultSeconds = toDouble() + other.toDouble();
    int resultMinutes = (resultSeconds ~/ 60).toInt();
    double resultRemainingSeconds = resultSeconds % 60;
    
    resultRemainingSeconds =
        double.tryParse(resultRemainingSeconds.toStringAsFixed(2)) ?? 0.0;
    return Time(
      minutes: resultMinutes,
      seconds: resultRemainingSeconds,
    );
  }

  bool lessThan(Time other) {
    return toDouble() < other.toDouble();
  }
}

