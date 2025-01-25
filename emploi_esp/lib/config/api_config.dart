// lib/config/api_config.dart

// API Configuration
class ApiConfig {
  // API Base URL
  static const String baseUrl = 'http://192.168.101.17:8000';

  // API Endpoints
  static const String departmentsEndpoint = '/api/departments/';
  static const String semestersEndpoint = '/api/departments/{department}/semesters/';
  static const String scheduleEndpoint = '/api/schedule/{department}/{semester}/{week}/';
  static const String bilanEndpoint = '/api/bilan/{department}/{semester}/';
  static const String coursesEndpoint = '/api/courses/{department}/{semester}/';

  // Storage Keys
  static const String scheduleKey = 'schedule_data';
  static const String bilanKey = 'bilan_data';
  static const String selectedDepartmentKey = 'selected_department';
  static const String selectedSemesterKey = 'selected_semester';

  // Debug mode
  static const bool debugMode = true;

  // Refresh Intervals
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration notificationInterval = Duration(minutes: 15);

  static const String progressEndpoint = '/api/progress/';

  static const String progressKey = 'progress_data';
  static const String coursesKey = 'courses_data';
}
