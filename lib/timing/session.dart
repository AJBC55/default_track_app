import 'racer_info.dart';
import 'timing_msgs.dart';

class TimingSession {
  String publisherId;
  bool byRacePos;
  Heartbeat raceStatus;
  RunInfo run;
  ClassInfo classData;
  List<RacerInfo> racers;

  TimingSession({
    this.publisherId = "",
    this.byRacePos = true,
    Heartbeat? raceStatus,
    RunInfo? run,
    ClassInfo? classData,
    List<RacerInfo>? racers,
    List<Time>? bestLapTimes,
  })  : raceStatus = raceStatus ?? Heartbeat(),
        run = run ?? RunInfo(),
        classData = classData ?? ClassInfo(),
        racers = racers ?? [];

  @override
  String toString() {
    return 'TimingSession(publisherId: $publisherId, raceStatus: $raceStatus, run: $run, classData: $classData, racers: $racers)';
  }

  factory TimingSession.fromJson(Map<String, dynamic> json) {
    return TimingSession(
      publisherId: json['publisherId'] ?? "",
      raceStatus: Heartbeat.fromJson(json['raceStatues'] ?? {}),
      run: RunInfo.fromJson(json['run'] ?? {}),
      classData: ClassInfo.fromJson(json['class'] ?? {}),
      racers: (json['racerData'] != null)
          ? (json['racerData'] as List<dynamic>)
              .map((item) => RacerInfo.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  void addSessionData() {
    for (int i = 0; i < racers.length; i++) {
      if (racers[i].racePosition.position != 1 && racers.length > 0) {
        racers[i].extra.gapToFirst = racers[i]
            .racePosition
            .totalTime
            .subtract(findRacerPos(1).racePosition.totalTime);

        if (i - 1 >= 0) {
          racers[i].extra.gapToNext = racers[i].racePosition.totalTime.subtract(
              findRacerPos(racers[i].racePosition.position - 1)
                  .racePosition
                  .totalTime);
        }
      } else {
        racers[i].extra.gapToFirst = Time(minutes: 0, seconds: 0.0);
        racers[i].extra.gapToNext = Time(minutes: 0, seconds: 0.0);
      }

      if (racers[i].passes.isNotEmpty) {
        int passesNum = racers[i].passes.length;
        racers[i].extra.previousLapTime =
            racers[i].passes[passesNum - 1].lapTime;
      } else {
        racers[i].extra.previousLapTime = Time();
      }
    }
  }

  void addCompetitor(CompInfo comp) {
    int racerIndex = findRacer(comp.regNumber);
    if (racerIndex != -1) {
      racers[racerIndex].firstName = comp.firstName;
      racers[racerIndex].registrationNumber = comp.regNumber;
      racers[racerIndex].number = comp.number;
      racers[racerIndex].classNumber = comp.classNumber;
      racers[racerIndex].nationality = comp.nationality;
      racers[racerIndex].lastName = comp.lastName;
    } else {
      racers.add(RacerInfo(
          registrationNumber: comp.regNumber,
          number: comp.number,
          classNumber: comp.classNumber,
          nationality: comp.nationality,
          firstName: comp.firstName,
          lastName: comp.lastName));
    }
  }

  int findRacer(String regNumber) {
    for (int i = 0; i < racers.length; i++) {
      if (racers[i].registrationNumber == regNumber) {
        return i;
      }
    }
    return -1;
  }

  RacerInfo findRacerPos(int pos) {
    for (int i = 0; i < racers.length; i++) {
      if (racers[i].racePosition.position == pos) {
        return racers[i];
      }
    }
    return RacerInfo();
  }

  void updateRacePos(RaceInfo racePos) {
    int racerIndex = findRacer(racePos.regNumber);

    if (racerIndex != -1) {
      racers[racerIndex].extra.previousPosition =
          racers[racerIndex].racePosition.position;
      racers[racerIndex].racePosition = racePos;
      sortRacePos();

      if (racers[racerIndex].racePosition.position != 1 && racers.length > 0) {
        racers[racerIndex].extra.gapToFirst = racers[racerIndex]
            .racePosition
            .totalTime
            .subtract(findRacerPos(1).racePosition.totalTime);

        if (racerIndex - 1 >= 0) {
          racers[racerIndex].extra.gapToNext = racers[racerIndex]
              .racePosition
              .totalTime
              .subtract(
                  findRacerPos(racers[racerIndex].racePosition.position - 1)
                      .racePosition
                      .totalTime);
        }
      } else {
        racers[racerIndex].extra.gapToFirst = Time(minutes: 0, seconds: 0.0);
        racers[racerIndex].extra.gapToNext = Time(minutes: 0, seconds: 0.0);
      }
    } else {}
  }

  void updatePQPosition(PracticeQualifyInfo pq) {
    int racerIndex = findRacer(pq.regNumber);
    if (racerIndex != -1) {
      racers[racerIndex].pqPosition = pq;
      sortRacePos();
    }
  }

  void addPass(PassingInfo pass) {
    int racerIndex = findRacer(pass.regNumber);
    if (racerIndex != -1) {
      if (!racers[racerIndex].passes.contains(pass) &&
          pass.lapTime != Time(minutes: 0, seconds: 0)) {
        racers[racerIndex].passes.add(pass);
      }

      if (pass.lapTime.lessThan(racers[racerIndex].extra.bestLapTime)) {
        racers[racerIndex].extra.bestLapTime = pass.lapTime;
      }

      racers[racerIndex].extra.previousLapTime = pass.lapTime;
    }
  }

  void updateRaceStatus(Heartbeat status) {
    raceStatus = status;
  }

  void updateRun(RunInfo run) {
    this.run = run;
  }

  void updateClass(ClassInfo classInfo) {
    classData = classInfo;
  }

  void sortRacePos() {
    if (byRacePos) {
      racers.sort((a, b) {
        if (a.racePosition.position == 0 && b.racePosition.position != 0) {
          return 1;
        } else if (b.racePosition.position == 0 &&
            a.racePosition.position != 0) {
          return -1;
        } else {
          return a.racePosition.position.compareTo(b.racePosition.position);
        }
      });
    } else {
      racers.sort((a, b) {
        double aLapTime = a.pqPosition.bestLapTime.toDouble();
        double bLapTime = b.pqPosition.bestLapTime.toDouble();

        if (aLapTime == 0.0 && bLapTime != 0.0) {
          return 1;
        } else if (bLapTime == 0.0 && aLapTime != 0.0) {
          return -1;
        } else {
          return aLapTime.compareTo(bLapTime);
        }
      });
    }
  }

  void clearSession() {
    classData = ClassInfo();
    run = RunInfo();
    raceStatus = Heartbeat();
    racers = [];
  }

  void sortPqPos() {
    for (int i = 1; i < racers.length; i++) {
      RacerInfo keyRacer = racers[i];
      int key = keyRacer.pqPosition.position;
      int j = i - 1;

      while (j >= 0 && racers[j].pqPosition.position > key) {
        racers[j + 1] = racers[j];
        j--;
      }

      racers[j + 1] = keyRacer;
    }
  }

  void updateByracePos(bool value) {
    byRacePos = value;
  }

  void processTimingFlag(data) {
    final messageType = data['type'];
    switch (messageType) {
      case 'F': // updates heartbeat every second
        Heartbeat heartbeat = Heartbeat.fromJson(data['data']);
        updateRaceStatus(heartbeat);
        break;
      case 'COMP': // adds competitor to the race
        CompInfo competitor = CompInfo.fromJson(data['data']);
        addCompetitor(competitor);
        break;
      case 'B': // updates run information
        RunInfo run = RunInfo.fromJson(data['data']);
        updateRun(run);
        break;
      case 'C': // updates class information
        ClassInfo classUpdate = ClassInfo.fromJson(data['data']);
        updateClass(classUpdate);
        break;
      case 'G': // updates race information
        RaceInfo raceUpdate = RaceInfo.fromJson(data['data']);
        updateRacePos(raceUpdate);
        break;
      case 'H': // updates practice/qualifying information
        PracticeQualifyInfo practiceUpdate =
            PracticeQualifyInfo.fromJson(data['data']);
        updatePQPosition(practiceUpdate);
        break;
      case 'J': // addes pass to competitor
        PassingInfo passes = PassingInfo.fromJson(data['data']);
        addPass(passes);
        break;
      case 'I': // resets session
        clearSession();
        break;

      default:
        print('Unknown message type: $messageType');
        break;
    }
    sortRacePos();
  }
}
