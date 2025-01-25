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
  BilanSemester? _bilanSemester;
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bilanSemester = await _apiService.getBilan(
        widget.departmentCode,
        widget.semesterCode,
      );
      setState(() {
        _bilanSemester = bilanSemester;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('API Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBilan,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              if (_error != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (_isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_bilanSemester != null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final bilan = _bilanSemester!.courses[index];
                      return _buildBilanCard(bilan);
                    },
                    childCount: _bilanSemester!.courses.length,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Center(
                    child: Text('No data available'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Progression des Cours',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBilanCard(Bilan bilan) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bilan.code,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              bilan.title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: bilan.totalProgress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress: ${bilan.totalProgress.toStringAsFixed(1)}%'),
                Text('Credits: ${bilan.credits}'),
              ],
            ),
            SizedBox(height: 16),
            _buildHoursRow('CM', bilan.cmCompleted, bilan.cmHours),
            _buildHoursRow('TD', bilan.tdCompleted, bilan.tdHours),
            _buildHoursRow('TP', bilan.tpCompleted, bilan.tpHours),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursRow(String type, double completed, double total) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$type Hours:'),
          Text('${completed.toStringAsFixed(1)}/${total.toStringAsFixed(1)}'),
        ],
      ),
    );
  }
}
