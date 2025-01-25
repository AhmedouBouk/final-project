class Bilan {
  final String code;
  final String title;
  final int credits;
  final double cmHours;
  final double tdHours;
  final double tpHours;
  final double cmCompleted;
  final double tdCompleted;
  final double tpCompleted;
  final double cmProgress;
  final double tdProgress;
  final double tpProgress;
  final double totalProgress;

  Bilan({
    required this.code,
    required this.title,
    required this.credits,
    required this.cmHours,
    required this.tdHours,
    required this.tpHours,
    required this.cmCompleted,
    required this.tdCompleted,
    required this.tpCompleted,
    required this.cmProgress,
    required this.tdProgress,
    required this.tpProgress,
    required this.totalProgress,
  });

  factory Bilan.fromJson(Map<String, dynamic> json) {
    return Bilan(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      credits: json['credits']?.toInt() ?? 0,
      cmHours: (json['cm_hours'] ?? 0).toDouble(),
      tdHours: (json['td_hours'] ?? 0).toDouble(),
      tpHours: (json['tp_hours'] ?? 0).toDouble(),
      cmCompleted: (json['cm_completed'] ?? 0).toDouble(),
      tdCompleted: (json['td_completed'] ?? 0).toDouble(),
      tpCompleted: (json['tp_completed'] ?? 0).toDouble(),
      cmProgress: (json['cm_progress'] ?? 0).toDouble(),
      tdProgress: (json['td_progress'] ?? 0).toDouble(),
      tpProgress: (json['tp_progress'] ?? 0).toDouble(),
      totalProgress: (json['total_progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    'credits': credits,
    'cm_hours': cmHours,
    'td_hours': tdHours,
    'tp_hours': tpHours,
    'cm_completed': cmCompleted,
    'td_completed': tdCompleted,
    'tp_completed': tpCompleted,
    'cm_progress': cmProgress,
    'td_progress': tdProgress,
    'tp_progress': tpProgress,
    'total_progress': totalProgress,
  };
}

class BilanSemester {
  final String departmentCode;
  final String semesterCode;
  final List<Bilan> courses;
  final double averageProgress;

  BilanSemester({
    required this.departmentCode,
    required this.semesterCode,
    required this.courses,
    required this.averageProgress,
  });

  factory BilanSemester.fromJson(Map<String, dynamic> json) {
    final List<dynamic> coursesJson = json['courses'] as List<dynamic>;
    final courses = coursesJson
        .where((course) =>
            course is Map<String, dynamic> &&
            course['code']?.toString().trim().isNotEmpty == true)
        .map((course) => Bilan.fromJson(course as Map<String, dynamic>))
        .toList();

    // Calculate average progress
    final totalProgress = courses.fold<double>(
        0, (sum, course) => sum + course.totalProgress);
    final averageProgress =
        courses.isNotEmpty ? totalProgress / courses.length : 0.0;

    return BilanSemester(
      departmentCode: json['department_code'] as String,
      semesterCode: json['semester_code'] as String,
      courses: courses,
      averageProgress: averageProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_code': departmentCode,
      'semester_code': semesterCode,
      'courses': courses.map((course) => course.toJson()).toList(),
      'average_progress': averageProgress,
    };
  }
}

class BilanData {
  final String courseCode;
  final int completedHours;
  final int plannedHours;
  final int progressPercentage;

  BilanData({
    required this.courseCode,
    required this.completedHours,
    required this.plannedHours,
    required this.progressPercentage,
  });

  factory BilanData.fromJson(Map<String, dynamic> json) {
    return BilanData(
      courseCode: json['course_code'] ?? '',
      completedHours: json['completed_hours']?.toInt() ?? 0,
      plannedHours: json['planned_hours']?.toInt() ?? 0,
      progressPercentage: json['progress_percentage']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'course_code': courseCode,
    'completed_hours': completedHours,
    'planned_hours': plannedHours,
    'progress_percentage': progressPercentage,
  };
}
