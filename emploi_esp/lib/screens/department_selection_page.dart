import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/semester_model.dart';
import '../models/department_model.dart';
import 'semester_selection_page.dart';

class DepartmentSelectionPage extends StatefulWidget {
  final Function(String, String)? onSelectionComplete;

  const DepartmentSelectionPage({
    Key? key,
    this.onSelectionComplete,
  }) : super(key: key);

  @override
  _DepartmentSelectionPageState createState() => _DepartmentSelectionPageState();
}

class _DepartmentSelectionPageState extends State<DepartmentSelectionPage> {
  final ApiService _apiService = ApiService();
  List<Department> departments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final fetchedDepartments = await _apiService.getDepartments();
      if (!mounted) return;

      setState(() {
        departments = fetchedDepartments;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Error loading departments: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _handleDepartmentSelection(Department department) async {
    try {
      // Always navigate to semester selection page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SemesterSelectionPage(
            departmentCode: department.code,
            departmentName: department.name,
            onSelectionComplete: widget.onSelectionComplete,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Department'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchDepartments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : departments.isEmpty
                  ? const Center(child: Text('No departments available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        final department = departments[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(department.name),
                            subtitle: Text('Code: ${department.code}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _handleDepartmentSelection(department),
                          ),
                        );
                      },
                    ),
    );
  }
}
