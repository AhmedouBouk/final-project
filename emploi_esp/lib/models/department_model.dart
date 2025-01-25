class Department {
  final String code;
  final String name;

  Department({
    required this.code,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}
