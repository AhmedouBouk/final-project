import 'dart:convert';
import 'dart:math';
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
      final response = await _retryRequest(() async {
        return await _client
            .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.departmentsEndpoint}'))
            .timeout(_timeout);
      });

      if (response.statusCode == 200) {
        if (ApiConfig.debugMode) {
          print('Raw departments response length: ${response.body.length}');
        }

        // Extract department information from HTML
        final departmentRegex = RegExp(
          r'<div class="department-card">.*?<h5 class="department-name">(.*?)</h5>.*?href="[^"]*?/([^/"]+)/semesters/"',
          multiLine: true,
          dotAll: true
        );
        
        final matches = departmentRegex.allMatches(response.body);
        final departments = matches.map((match) => Department(
          name: match.group(1)?.trim() ?? '',
          code: match.group(2)?.trim() ?? '',
        )).toList();

        if (departments.isEmpty && ApiConfig.debugMode) {
          print('No departments found in HTML. First 500 chars of response:');
          print(response.body.substring(0, response.body.length > 500 ? 500 : response.body.length));
          
          // Check if there are no departments available message
          if (response.body.contains('Aucun département disponible')) {
            print('Server indicates no departments are available');
          }
        }

        return departments;
      } else {
        print('Failed to load departments. Status code: ${response.statusCode}');
        if (ApiConfig.debugMode) {
          print('Response body: ${response.body}');
        }
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      print('Error fetching departments: $e');
      rethrow;
    }
  }

  Future<List<Semester>> getSemesters(String departmentCode) async {
    try {
      final endpoint = ApiConfig.semestersEndpoint.replaceAll('{department}', departmentCode);
      final response = await _retryRequest(() async {
        return await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);
      });

      if (response.statusCode == 200) {
        if (ApiConfig.debugMode) {
          print('Raw response length: ${response.body.length}');
        }

        // Extract semester information from HTML
        final semesterRegex = RegExp(
          r'<div class="semester-card">.*?<h5 class="semester-name">(.*?)</h5>.*?href="[^"]*?/[^/]+/([^/"]+)/schedule/"',
          multiLine: true,
          dotAll: true
        );
        
        final matches = semesterRegex.allMatches(response.body);
        final semesters = matches.map((match) {
          final displayName = match.group(1)?.trim() ?? '';
          final code = match.group(2)?.trim() ?? '';
          
          return Semester(
            code: code,
            departmentCode: departmentCode,
            displayName: displayName,
          );
        }).toList();

        if (semesters.isEmpty && ApiConfig.debugMode) {
          print('No semesters found in HTML. First 500 chars of response:');
          print(response.body.substring(0, response.body.length > 500 ? 500 : response.body.length));
          
          // Check if there are no semesters available message
          if (response.body.contains('Aucun semestre disponible')) {
            print('Server indicates no semesters are available');
          }
        }

        return semesters;
      } else {
        print('Failed to load semesters. Status code: ${response.statusCode}');
        if (ApiConfig.debugMode) {
          print('Response body: ${response.body}');
        }
        throw Exception('Failed to load semesters');
      }
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
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> scheduleList = data['schedule'] ?? [];
        print('Schedule data: $scheduleList'); // Debug print
        return scheduleList.map((json) => ScheduleSession.fromJson(json)).toList();
      } else {
        print('Failed to load schedule. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('Error getting schedule: $e');
      rethrow;
    }
  }

  Future<List<BilanData>> getBilan(String departmentCode, String semesterCode) async {
    try {
      final endpoint = ApiConfig.bilanEndpoint
          .replaceAll('{department}', departmentCode)
          .replaceAll('{semester}', semesterCode);
      
      final response = await _retryRequest(() async {
        return await _client
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'))
            .timeout(_timeout);
      });

      if (response.statusCode == 200) {
        if (ApiConfig.debugMode) {
          print('Raw bilan response length: ${response.body.length}');
        }

        // First, check if we can find the tbody section
        final tbodyMatch = RegExp(
          r'<tbody>(.*?)</tbody>',
          dotAll: true,
        ).firstMatch(response.body);

        if (tbodyMatch == null) {
          print('Could not find tbody in HTML');
          if (ApiConfig.debugMode) {
            print('HTML content around where tbody should be:');
            final tableIndex = response.body.indexOf('<table');
            if (tableIndex != -1) {
              final start = tableIndex;
              final end = start + 500;
              print(response.body.substring(start, end < response.body.length ? end : response.body.length));
            }
          }
          return [];
        }

        final tbodyContent = tbodyMatch.group(1) ?? '';
        if (ApiConfig.debugMode) {
          print('Found tbody content. Length: ${tbodyContent.length}');
          print('First 200 chars of tbody:');
          print(tbodyContent.substring(0, tbodyContent.length > 200 ? 200 : tbodyContent.length));
        }

        // Extract bilan information from table rows
        final rowRegex = RegExp(
          r'<tr>\s*' +
          r'<td>([^<]+)</td>\s*' +  // Course code
          r'<td>[^<]+</td>\s*' +    // Title (skip)
          r'<td>(\d+)</td>\s*' +    // Credits
          r'<td>(\d+)</td>\s*' +    // CM Planned
          r'<td class="editable"[^>]*>(\d+(?:,\d+)?)</td>\s*' +  // CM Completed
          r'<td class="progress-cell">[\d,]+%</td>\s*' +         // CM % (skip)
          r'<td>(\d+)</td>\s*' +    // TD Planned
          r'<td class="editable"[^>]*>(\d+(?:,\d+)?)</td>\s*' +  // TD Completed
          r'<td class="progress-cell">[\d,]+%</td>\s*' +         // TD % (skip)
          r'<td>(\d+)</td>\s*' +    // TP Planned
          r'<td class="editable"[^>]*>(\d+(?:,\d+)?)</td>\s*' +  // TP Completed
          r'<td class="progress-cell">[\d,]+%</td>\s*' +         // TP % (skip)
          r'<td>(\d+)</td>\s*' +    // Total Planned
          r'<td>(\d+(?:,\d+)?)</td>\s*' +  // Total Completed
          r'<td class="progress-cell">([\d,]+)%</td>',  // Total %
          multiLine: true,
          dotAll: true,
        );
        
        final matches = rowRegex.allMatches(tbodyContent);
        if (ApiConfig.debugMode) {
          print('Found ${matches.length} bilan rows');
        }

        final bilanDataList = matches.map((match) {
          try {
            double parseNumber(String? value) {
              if (value == null || value.isEmpty) return 0.0;
              // Remove any whitespace and % sign
              value = value.trim().replaceAll('%', '');
              // Handle both integer and decimal numbers with comma separator
              if (!value.contains(',')) {
                return double.parse(value);
              }
              // For decimal numbers, replace comma with dot
              final parts = value.split(',');
              if (parts.length != 2) return 0.0;
              return double.parse('${parts[0]}.${parts[1]}');
            }

            final code = match.group(1)?.trim() ?? '';
            
            // Calculate total planned hours from individual components
            final cmPlanned = int.parse(match.group(3) ?? '0');
            final tdPlanned = int.parse(match.group(5) ?? '0');
            final tpPlanned = int.parse(match.group(7) ?? '0');
            final totalPlanned = cmPlanned + tdPlanned + tpPlanned;

            // Parse completed hours
            final cmCompleted = parseNumber(match.group(4));
            final tdCompleted = parseNumber(match.group(6));
            final tpCompleted = parseNumber(match.group(8));
            final totalCompleted = cmCompleted + tdCompleted + tpCompleted;

            // Parse progress percentage
            final totalProgress = parseNumber(match.group(10));

            if (ApiConfig.debugMode) {
              print('Parsed row: $code');
              print('  CM: $cmPlanned planned, $cmCompleted completed');
              print('  TD: $tdPlanned planned, $tdCompleted completed');
              print('  TP: $tpPlanned planned, $tpCompleted completed');
              print('  Total: $totalPlanned planned, $totalCompleted completed, $totalProgress%');
            }

            return BilanData(
              courseCode: code,
              completedHours: totalCompleted.round(),
              plannedHours: totalPlanned,
              progressPercentage: totalProgress.round(),
            );
          } catch (e) {
            print('Error parsing bilan row: $e');
            if (ApiConfig.debugMode) {
              print('Match groups: ${List.generate(match.groupCount + 1, (i) => match.group(i))}');
            }
            rethrow;
          }
        }).toList();

        if (bilanDataList.isEmpty && ApiConfig.debugMode) {
          print('No bilan data found in HTML. First 500 chars of response:');
          print(response.body.substring(0, response.body.length > 500 ? 500 : response.body.length));
        }

        return bilanDataList;
      } else {
        print('Failed to load bilan. Status code: ${response.statusCode}');
        if (ApiConfig.debugMode) {
          print('Response body: ${response.body}');
        }
        throw Exception('Failed to load bilan');
      }
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