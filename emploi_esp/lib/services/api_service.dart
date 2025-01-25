import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/schedule_model.dart';
import '../models/bilan_model.dart';
import '../models/department_model.dart';
import '../models/semester_model.dart';
import '../services/storage_service.dart';

class ApiService {
  final http.Client _client = http.Client();
  final StorageService _storage = StorageService();
  final Duration _timeout = const Duration(seconds: 10);
  final int _maxRetries = 3;

  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        return await request();
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    throw Exception('Failed after $_maxRetries retries');
  }

  // Check for updates
  Future<bool> checkForUpdates() async {
    try {
      final currentWeek = 1; // Start with week 1 by default
      final defaultDepartment = 'DEFAULT'; // Default department code
      final defaultSemester = 'S1'; // Default semester code

      final endpoint = ApiConfig.scheduleEndpoint
          .replaceAll('{department}', defaultDepartment)
          .replaceAll('{semester}', defaultSemester)
          .replaceAll('{week}', currentWeek.toString());

      final response = await _retryRequest(() async {
        return await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          // If data is a map, it might contain a list under a specific key
          final List<dynamic> newData = data['sessions'] ?? [];
          final cachedData = await _storage.getData(ApiConfig.scheduleKey);
          
          if (cachedData == null) {
            await _storage.saveData(ApiConfig.scheduleKey, {'data': newData});
            return true;
          }

          // Compare the new data with cached data
          final hasChanges = json.encode(newData) != json.encode(cachedData['data']);
          if (hasChanges) {
            await _storage.saveData(ApiConfig.scheduleKey, {'data': newData});
          }
          return hasChanges;
        } else if (data is List) {
          // If data is already a list, use it directly
          final List<dynamic> newData = data;
          final cachedData = await _storage.getData(ApiConfig.scheduleKey);
          
          if (cachedData == null) {
            await _storage.saveData(ApiConfig.scheduleKey, {'data': newData});
            return true;
          }

          // Compare the new data with cached data
          final hasChanges = json.encode(newData) != json.encode(cachedData['data']);
          if (hasChanges) {
            await _storage.saveData(ApiConfig.scheduleKey, {'data': newData});
          }
          return hasChanges;
        } else {
          throw Exception('Invalid schedule data format');
        }
      }
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  // Get schedule metadata
  Future<ScheduleMetadata> getScheduleMetadata(
    String departmentCode,
    String semesterCode,
    int week,
  ) async {
    try {
      final endpoint = ApiConfig.scheduleEndpoint
          .replaceAll('{department}', departmentCode)
          .replaceAll('{semester}', semesterCode)
          .replaceAll('{week}', week.toString());

      final response = await _retryRequest(() async {
        return await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Create metadata from schedule data
        return ScheduleMetadata(
          departmentCode: departmentCode,
          semesterCode: semesterCode,
          week: week,
          startDate: DateTime.now(),  // These can be enhanced later
          endDate: DateTime.now().add(const Duration(days: 7)),
        );
      } else {
        throw Exception('Failed to load schedule metadata');
      }
    } catch (e) {
      print('Error getting schedule metadata: $e');
      rethrow;
    }
  }

  Future<List<Department>> getDepartments() async {
    try {
      return await _retryRequest(() async {
        final response = await _client
            .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.departmentsEndpoint}'))
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((json) => Department.fromJson(json)).toList();
        } else {
          print('Failed to load departments. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to load departments');
        }
      });
    } catch (e) {
      print('Error getting departments: $e');
      rethrow;
    }
  }

  Future<List<Semester>> getSemesters(String departmentCode) async {
    try {
      return await _retryRequest(() async {
        final endpoint = ApiConfig.semestersEndpoint.replaceAll('{department}', departmentCode);
        final response = await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          print('Semester data: $data'); // Debug print
          return data.map((json) {
            try {
              return Semester.fromJson(json);
            } catch (e) {
              print('Error parsing semester: $e');
              print('Problematic JSON: $json');
              rethrow;
            }
          }).toList();
        } else {
          print('Failed to load semesters. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to load semesters');
        }
      });
    } catch (e) {
      print('Error getting semesters: $e');
      rethrow;
    }
  }

  Future<List<ScheduleSession>> getScheduleSessions(
    String departmentCode,
    String semesterCode,
    int week,
  ) async {
    try {
      return await _retryRequest(() async {
        final endpoint = ApiConfig.scheduleEndpoint
            .replaceAll('{department}', departmentCode)
            .replaceAll('{semester}', semesterCode)
            .replaceAll('{week}', week.toString());

        final response = await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> scheduleList = data['schedule'] ?? [];
          print('Schedule data: $scheduleList'); // Debug print
          return scheduleList.map((json) => ScheduleSession.fromJson(json)).toList();
        } else {
          print('Failed to load schedule. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to load schedule');
        }
      });
    } catch (e) {
      print('Error getting schedule: $e');
      rethrow;
    }
  }

  Future<BilanSemester> getBilan(String departmentCode, String semesterCode) async {
    try {
      return await _retryRequest(() async {
        final endpoint = ApiConfig.bilanEndpoint
            .replaceAll('{department}', departmentCode)
            .replaceAll('{semester}', semesterCode);

        final response = await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Bilan data: $data'); // Debug print
          return BilanSemester.fromJson(data);
        } else {
          print('Failed to load bilan. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to load bilan');
        }
      });
    } catch (e) {
      print('Error getting bilan data: $e');
      rethrow;
    }
  }

  String _convertDay(String day) {
    final Map<String, String> dayMap = {
      'MON': 'LUN',
      'TUE': 'MAR',
      'WED': 'MER',
      'THU': 'JEU',
      'FRI': 'VEN',
      'SAT': 'SAM',
      'SUN': 'DIM',
    };
    return dayMap[day.toUpperCase()] ?? day;
  }

  int _convertPeriodToTimeSlot(String period) {
    if (ApiConfig.debugMode) {
      print('Converting period: $period');
    }
    final periodMap = {
      'P1': 1,
      'P2': 2,
      'P3': 3,
      'P4': 4,
      'P5': 5,
      'P6': 6,
    };
    return periodMap[period] ?? 1;
  }

  // Dispose the HTTP client
  Future<void> dispose() async {
    _client.close();
  }
  
  String _handleError(Object e) {
    print('API Error: $e');
    if (e is Exception) {
      return e.toString();
    }
    return 'An unexpected error occurred';
  }
}