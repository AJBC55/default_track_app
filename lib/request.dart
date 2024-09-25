import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_models.dart';
import 'factory.dart';

class Requests {
  Future<List<Event>?> geteventsData({String search = "", int skip = 0}) async {
    String queryParams = "?search=$search&skip=$skip";
    try {
      Uri url = Uri.parse(geteventsUrl + queryParams);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => Event.fromJson(e)).toList();
        } else {
          return null;
        }
      } else {
        print("Failed with status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Future<List<News>?> getNewsData({String search = "", int skip = 0}) async {
    String queryParams = "?search=$search&skip=$skip";
    try {
      Uri url = Uri.parse(getNewsUrl + queryParams);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => News.fromJson(e)).toList();
        } else {
          return null;
        }
      } else {
        print("Failed with status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Stream<Map<String, dynamic>> getTimingData() async* {
    final url = Uri.parse(getTimingURl);
    final client = http.Client();
    final request = await client.send(http.Request('GET', url));

    final stream =
        request.stream.transform(utf8.decoder).transform(LineSplitter());

    await for (final line in stream) {
      try {
        final cleanedLine =
            line.startsWith('data: ') ? line.substring(6) : line;
        if (cleanedLine.trim().isNotEmpty) {
          final data = json.decode(cleanedLine) as Map<String, dynamic>;
          yield data;
          print(data);
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    }
  }
}
