import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/semester_model.dart';

class SemesterSelectionPage extends StatefulWidget {
  final String departmentCode;
  final String departmentName;
  final Function(String, String)? onSelectionComplete;

  const SemesterSelectionPage({
    Key? key,
    required this.departmentCode,
    required this.departmentName,
    this.onSelectionComplete,
  }) : super(key: key);

  @override
  _SemesterSelectionPageState createState() => _SemesterSelectionPageState();
}

class _SemesterSelectionPageState extends State<SemesterSelectionPage> {
  final ApiService _apiService = ApiService();
  List<Semester> semesters = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSemesters();
  }

  Future<void> fetchSemesters() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final fetchedSemesters = await _apiService.getSemesters(widget.departmentCode);
      if (!mounted) return;

      setState(() {
        semesters = fetchedSemesters;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Error loading semesters: $e';
        isLoading = false;
      });
    }
  }

  void _handleSemesterSelection(Semester semester) {
    if (widget.onSelectionComplete != null) {
      widget.onSelectionComplete!(widget.departmentCode, semester.code);
    }
    Navigator.pop(context); // Return to previous screen after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.departmentName} Semesters'),
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
                        onPressed: fetchSemesters,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : semesters.isEmpty
                  ? const Center(child: Text('No semesters available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: semesters.length,
                      itemBuilder: (context, index) {
                        final semester = semesters[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(semester.displayName ?? 'Semester ${semester.code}'),
                            subtitle: Text('Code: ${semester.code}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _handleSemesterSelection(semester),
                          ),
                        );
                      },
                    ),
    );
  }
}
