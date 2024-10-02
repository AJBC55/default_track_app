import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:default_track_app/factory.dart';

class TimingStreamManager {
  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

  TimingStreamManager() {
    _startStreaming();
  }

  Stream<Map<String, dynamic>> get timingStream => _controller.stream;

  void _startStreaming() async {
    final url = Uri.parse(getTimingURl);
    final client = http.Client();
    final request = await client.send(http.Request('GET', url));

    final stream =
        request.stream.transform(utf8.decoder).transform(LineSplitter());

    await for (final line in stream) {
      if (_controller.isClosed) break;
      try {
        final cleanedLine =
            line.startsWith('data: ') ? line.substring(6) : line;
        if (cleanedLine.trim().isNotEmpty) {
          final data = json.decode(cleanedLine) as Map<String, dynamic>;
          _controller.add(data);
          print(data);
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    }
  }

  void close() {
    _controller.close();
  }
}