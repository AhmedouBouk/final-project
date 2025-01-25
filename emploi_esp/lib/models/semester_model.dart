class Semester {
  final String code;
  final String departmentCode;
  final String displayName;

  Semester({
    required this.code,
    required this.departmentCode,
    required this.displayName,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    final code = json['code'];
    final departmentCode = json['department_code'];
    final displayName = json['display_name'];

    if (code == null || departmentCode == null || displayName == null) {
      print('Invalid semester data:');
      print('code: $code');
      print('department_code: $departmentCode');
      print('display_name: $displayName');
      throw FormatException('Missing required fields in semester data');
    }

    return Semester(
      code: code as String,
      departmentCode: departmentCode as String,
      displayName: displayName as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'department_code': departmentCode,
      'display_name': displayName,
    };
  }

  @override
  String toString() {
    return 'Semester{code: $code, departmentCode: $departmentCode, displayName: $displayName}';
  }
}
