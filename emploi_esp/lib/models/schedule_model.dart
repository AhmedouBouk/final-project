// lib/models/schedule_model.dart

class ScheduleMetadata {
  final String departmentCode;
  final String semesterCode;
  final int week;
  final DateTime startDate;
  final DateTime endDate;

  ScheduleMetadata({
    required this.departmentCode,
    required this.semesterCode,
    required this.week,
    required this.startDate,
    required this.endDate,
  });

  factory ScheduleMetadata.fromJson(Map<String, dynamic> json) {
    return ScheduleMetadata(
      departmentCode: json['department_code'],
      semesterCode: json['semester_code'],
      week: json['week'],
      startDate: DateTime.parse(json['date_range']['start']),
      endDate: DateTime.parse(json['date_range']['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_code': departmentCode,
      'semester_code': semesterCode,
      'week': week,
      'date_range': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
    };
  }
}

class ScheduleSession {
  final String course;
  final String type;
  final String? room;
  final String professor;
  final String period;
  final String day;

  ScheduleSession({
    required this.course,
    required this.type,
    this.room,
    required this.professor,
    required this.period,
    required this.day,
  });

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      course: json['course'] ?? '',
      type: json['type'] ?? '',
      room: json['room'],
      professor: json['professor'] ?? 'Non assigné',
      period: json['period'] ?? '',
      day: json['day'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'type': type,
      'room': room,
      'professor': professor,
      'period': period,
      'day': day,
    };
  }

  bool get isOnline => room == null || room!.isEmpty;

  int get periodNumber {
    final match = RegExp(r'\d+').firstMatch(period);
    return match != null ? int.parse(match.group(0)!) : 0;
  }
}