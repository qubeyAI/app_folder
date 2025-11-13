import 'dart:convert';

enum LevelStatus { locked, unlocked, completed }

class Level {
  int idx;
  int amount;
  LevelStatus status;  // this replaces old 'String status'
  int progress; // total money saved till this level
  String? lastUpi;

  Level({
    required this.idx,
    required this.amount,
    this.status = LevelStatus.locked,
    this.progress = 0,
    this.lastUpi,
  });

  // Convert Level object to JSON
  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'amount': amount,
      'status': status.name,
      'progress': progress,
      'lastUpi': lastUpi,
    };
  }

  // Convert JSON to Level object
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      idx: json['idx'],
      amount: json['amount'],
      status: LevelStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => LevelStatus.locked),
      progress: json['progress'] ?? 0,
      lastUpi: json['lastUpi'],
    );
  }
}

// Helper functions for list of levels
List<Level> levelsFromJson(List<dynamic> jsonList) {
  return jsonList.map((e) => Level.fromJson(e)).toList();
}

List<Map<String, dynamic>> levelsToJson(List<Level> levels) {
  return levels.map((e) => e.toJson()).toList();
}