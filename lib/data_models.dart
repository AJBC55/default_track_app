/* Event Data Structure */
class Event {
  final int id;
  final String name;
  final String description;
  final dynamic date;
  final dynamic time;
  final int hour;
  final String minute;
  final dynamic eventEnd;
  final Uri ticketLink;
  final String imageLink;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.hour,
    required this.minute,
    required this.eventEnd,
    required this.ticketLink,
    required this.imageLink,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['eventStart'].split("T")[0] ?? '',
      time: json['eventStart'].split("T")[1].split("Z")[0] ?? '',
      hour: int.parse(json['eventStart'].split("T")[1].split(":")[0]),
      minute: json['eventStart'].split("T")[1].split(":")[1] ?? 0,
      eventEnd: json['eventEnd'] ?? '',
      ticketLink: Uri.tryParse(json['ticketLink']) ?? Uri(),
      imageLink: json['imageLink'] ?? '',
    );
  }
}

/* News Data Structure */
class News {
  final int id;
  final String name;
  final String description;
  final String imageLink;

  News({
    required this.id,
    required this.name,
    required this.description,
    required this.imageLink,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? 0,
      name: json['title'] ?? '',
      description: json['body'] ?? '',
      imageLink: json['imgLink'] ?? '',
    );
  }
}

/* Notification Token Data Structure */
class TokenData {
  final String token_type;
  final String jwt_token;

  TokenData({required this.token_type, required this.jwt_token});

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
        token_type: json["token_type"], jwt_token: json["jwt_token"]);
  }
}

/* */















