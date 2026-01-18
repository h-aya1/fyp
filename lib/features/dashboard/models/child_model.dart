


class MasteryRecord {
  final String character;
  int attempts;
  int successes;
  DateTime lastAttempt;

  MasteryRecord({
    required this.character,
    this.attempts = 0,
    this.successes = 0,
    required this.lastAttempt,
  });

  double get successRate => attempts == 0 ? 0 : successes / attempts;

  Map<String, dynamic> toJson() => {
    'character': character,
    'attempts': attempts,
    'successes': successes,
    'lastAttempt': lastAttempt.toIso8601String(),
  };

  factory MasteryRecord.fromJson(Map<String, dynamic> json) => MasteryRecord(
    character: json['character'],
    attempts: json['attempts'],
    successes: json['successes'],
    lastAttempt: DateTime.parse(json['lastAttempt']),
  );
}

class Child {
  final String id;
  final String name;
  final String avatar;
  List<MasteryRecord> mastery;

  Child({
    required this.id,
    required this.name,
    required this.avatar,
    required this.mastery,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'mastery': mastery.map((m) => m.toJson()).toList(),
  };

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      mastery: (json['mastery'] as List)
          .map((m) => MasteryRecord.fromJson(m))
          .toList(),
    );
  }
}
