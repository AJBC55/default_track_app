import 'package:flutter/material.dart';
import 'timing_stream.dart';
import 'session.dart';

class TimingSessionProvider extends ChangeNotifier {
  TimingStreamManager _streamManager = TimingStreamManager();
  TimingSession _session = TimingSession();
  bool _byRacePos = true;

  TimingSession get session => _session;
  bool get byRacePos => _byRacePos;

  TimingSessionProvider() {
    _streamManager = TimingStreamManager();
    _startListening();
  }

  void _startListening() {
    _streamManager.timingStream.listen((data) {
      if (data["publisherId"] != null) {
        _session = TimingSession.fromJson(data);
        _session.addSessionData();
        _session.sortRacePos();
      } else {
        _session.processTimingFlag(data);
        _session.sortRacePos();
      }
      notifyListeners();
    });
  }

  void stopStreaming() {
    _streamManager.close();
    _session.clearSession();
    notifyListeners();
  }

  void startStreaming() {
    stopStreaming();
    _streamManager = TimingStreamManager();
    _session.clearSession();
    _startListening();
    notifyListeners();
  }

  void toggleByRacePos() {
    _byRacePos = !_byRacePos;
    _session.byRacePos = _byRacePos;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamManager.close();
    super.dispose();
  }
}
