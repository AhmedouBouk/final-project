// lib/models/progress_model.dart

class CourseProgress {
  final String codeEM;
  final String titre;
  final int creditsEM;
  final Map<String, int> planification;
  final Map<String, int> realisation;
  final Map<String, double> avancement;

  CourseProgress({
    required this.codeEM,
    required this.titre,
    required this.creditsEM,
    required this.planification,
    required this.realisation,
    required this.avancement,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      codeEM: json['code_em'],
      titre: json['titre'],
      creditsEM: json['credits_em'],
      planification: Map<String, int>.from(json['planification']),
      realisation: Map<String, int>.from(json['realisation']),
      avancement: Map<String, double>.from(json['avancement']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code_em': codeEM,
      'titre': titre,
      'credits_em': creditsEM,
      'planification': planification,
      'realisation': realisation,
      'avancement': avancement,
    };
  }
}

class GlobalProgress {
  final String lastUpdate;
  final Map<String, double> globalProgress;
  final int totalSessionsPlanned;
  final int totalSessionsCompleted;
  final int totalCourses;
  final int totalCredits;

  GlobalProgress({
    required this.lastUpdate,
    required this.globalProgress,
    required this.totalSessionsPlanned,
    required this.totalSessionsCompleted,
    required this.totalCourses,
    required this.totalCredits,
  });

  factory GlobalProgress.fromJson(Map<String, dynamic> json) {
    return GlobalProgress(
      lastUpdate: json['last_update'],
      globalProgress: Map<String, double>.from(json['global_progress']),
      totalSessionsPlanned: json['total_sessions_planned'],
      totalSessionsCompleted: json['total_sessions_completed'],
      totalCourses: json['total_courses'],
      totalCredits: json['total_credits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_update': lastUpdate,
      'global_progress': globalProgress,
      'total_sessions_planned': totalSessionsPlanned,
      'total_sessions_completed': totalSessionsCompleted,
      'total_courses': totalCourses,
      'total_credits': totalCredits,
    };
  }
}
