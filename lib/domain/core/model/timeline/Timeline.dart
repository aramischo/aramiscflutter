class Timeline {
  int? id;
  String? title;
  String? date;
  String? description;
  String? file;
  String? createdAt;

  Timeline({this.id, this.title, this.date, this.description, this.file, this.createdAt});

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      description: json['description'],
      file: json['file'],
      createdAt: json['created_at'],
    );
  }
}

class TimelineList {
  List<Timeline> timelines;

  TimelineList(this.timelines);

  factory TimelineList.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data']['timelines'] ?? [];
    return TimelineList(list.map((i) => Timeline.fromJson(i)).toList());
  }
}
