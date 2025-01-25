import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../models/bilan_model.dart';
import '../services/api_service.dart';

class BilanPage extends StatefulWidget {
  final String departmentCode;
  final String semesterCode;

  const BilanPage({
    Key? key,
    required this.departmentCode,
    required this.semesterCode,
  }) : super(key: key);

  @override
  _BilanPageState createState() => _BilanPageState();
}

class _BilanPageState extends State<BilanPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<BilanData>? _bilanData;
  String? _error;
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _fetchBilan();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchBilan() async {
    try {
      final data = await _apiService.getBilan(widget.departmentCode, widget.semesterCode);
      if (mounted) {
        setState(() {
          _bilanData = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Une erreur s\'est produite lors du chargement des données.';
          _isLoading = false;
        });
      }
      print('API Error: $e');
    }
  }

  Widget _buildBilanCard(BilanData bilan) {
    final progress = bilan.progressPercentage.toDouble();
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bilan.courseCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heures prévues: ${bilan.plannedHours}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Heures complétées: ${bilan.completedHours}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: progress >= 100 ? Colors.green : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Progression',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 100 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchBilan();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_bilanData == null || _bilanData!.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bilan - ${widget.departmentCode} - ${widget.semesterCode}'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _bilanData!.length,
          itemBuilder: (context, index) => _buildBilanCard(_bilanData![index]),
        ),
      ),
    );
  }
}
