import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/department_selection_page.dart';
import 'screens/emploi_page.dart';
import 'screens/bilan_page.dart';
import 'services/storage_service.dart';
import 'config/api_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emploi ESP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1; // Start with Emploi selected (middle)
  final StorageService _storage = StorageService();
  String? selectedDepartment;
  String? selectedSemester;

  @override
  void initState() {
    super.initState();
    _loadSavedSelections();
  }

  Future<void> _loadSavedSelections() async {
    final dept = await _storage.getData(ApiConfig.selectedDepartmentKey);
    final sem = await _storage.getData(ApiConfig.selectedSemesterKey);
    if (mounted) {
      setState(() {
        selectedDepartment = dept?['code'];
        selectedSemester = sem?['code'];
      });
    }
  }

  Future<void> _saveSelections(String department, String semester) async {
    await _storage.saveData(ApiConfig.selectedDepartmentKey, {'code': department});
    await _storage.saveData(ApiConfig.selectedSemesterKey, {'code': semester});
    if (mounted) {
      setState(() {
        selectedDepartment = department;
        selectedSemester = semester;
        _selectedIndex = 1; // Always show Emploi after selection
      });
    }
  }

  void _changeDepartment() {
    setState(() {
      selectedDepartment = null;
      selectedSemester = null;
    });
    _storage.clearData(ApiConfig.selectedDepartmentKey);
    _storage.clearData(ApiConfig.selectedSemesterKey);
  }

  Widget _getPage() {
    if (selectedDepartment == null || selectedSemester == null) {
      return DepartmentSelectionPage(
        onSelectionComplete: _saveSelections,
      );
    }

    switch (_selectedIndex) {
      case 0: // Left - Department Selection
        _changeDepartment();
        return DepartmentSelectionPage(
          onSelectionComplete: _saveSelections,
        );
      case 1: // Middle - Emploi
        return EmploiPage(
          departmentCode: selectedDepartment!,
          semesterCode: selectedSemester!,
        );
      case 2: // Right - Bilan
        return BilanPage(
          departmentCode: selectedDepartment!,
          semesterCode: selectedSemester!,
        );
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(),
      bottomNavigationBar: selectedDepartment != null && selectedSemester != null
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.arrow_back),
                  label: 'Back',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Emploi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Bilan',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : null,
    );
  }
}
