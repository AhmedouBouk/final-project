// lib/config/api_config.dart

// API Configuration
class ApiConfig {
  // API Base URL
  static const String baseUrl = 'http://192.168.101.17:8000';

  // Main Endpoints (HTML)
  static const String departmentsEndpoint = '/home';  // Department selection page
  static const String semestersEndpoint = '/{department}/semesters/';  // Semester selection page
  static const String bilanEndpoint = '/{department}/{semester}/bilan/';  // Bilan page

  // API Endpoints (JSON)
  static const String scheduleEndpoint = '/api/{department}/{semester}/schedule/{week}/';  // Get schedule
  static const String planEndpoint = '/api/{department}/{semester}/plan/{week}/';  // Get plan
  static const String coursesEndpoint = '/api/{department}/{semester}/courses/';  // Get courses
  static const String professorsEndpoint = '/api/{department}/{semester}/professors/';  // Get professors
  static const String roomsEndpoint = '/api/{department}/{semester}/rooms/';  // Get rooms

  // API Authentication
  static const String loginEndpoint = '/login/';
  static const String logoutEndpoint = '/logout/';

  // Storage Keys
  static const String scheduleKey = 'schedule_data';
  static const String bilanKey = 'bilan_data';
  static const String selectedDepartmentKey = 'selected_department';
  static const String selectedSemesterKey = 'selected_semester';
  static const String authTokenKey = 'auth_token';

  // Debug mode
  static const bool debugMode = true;

  // Refresh Intervals
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration notificationInterval = Duration(minutes: 15);

  // Cache Keys
  static const String progressKey = 'progress_data';
  static const String coursesKey = 'courses_data';
}
