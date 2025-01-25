import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../models/course_model.dart';
import '../models/schedule_model.dart';
import '../services/api_service.dart';

class EmploiPage extends StatefulWidget {
  final String departmentCode;
  final String semesterCode;

  const EmploiPage({
    Key? key,
    required this.departmentCode,
    required this.semesterCode,
  }) : super(key: key);

  @override
  State<EmploiPage> createState() => _EmploiPageState();
}

class _EmploiPageState extends State<EmploiPage> {
  final ApiService _apiService = ApiService();
  List<ScheduleSession>? _sessions;
  String? _error;
  bool _isLoading = true;
  String _selectedDay = 'LUN';
  final List<String> _days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'];
  int _currentWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _apiService.getScheduleSessions(
        widget.departmentCode,
        widget.semesterCode,
        _currentWeek,
      );
      setState(() {
        _sessions = sessions;
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

  List<ScheduleSession> _getSessionsForDay(String day) {
    if (_sessions == null) return [];
    return _sessions!.where((session) => session.day == day).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }

  String _getTimeSlot(String period) {
    final periodNum = int.tryParse(period.replaceAll('P', '')) ?? 0;
    switch (periodNum) {
      case 1:
        return '8:30 - 10:00';
      case 2:
        return '10:15 - 11:45';
      case 3:
        return '12:00 - 13:30';
      case 4:
        return '13:45 - 15:15';
      case 5:
        return '15:30 - 17:00';
      case 6:
        return '17:15 - 18:45';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSchedule,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: _buildDaySelector(),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: _buildSessionsList(),
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
        title: const Text(''),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 18),
                    onPressed: _currentWeek > 1
                        ? () {
                            setState(() {
                              _currentWeek--;
                              _loadSchedule();
                            });
                          }
                        : null,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _currentWeek,
                          dropdownColor: Theme.of(context).colorScheme.primary,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white, size: 20),
                          items: List.generate(
                            15,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(
                                'Semaine ${index + 1}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _currentWeek = value;
                                _loadSchedule();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 18),
                    onPressed: _currentWeek < 15
                        ? () {
                            setState(() {
                              _currentWeek++;
                              _loadSchedule();
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = day == _selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedDay = day),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildShimmerCard(),
          childCount: 3,
        ),
      );
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur: $_error',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadSchedule,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final sessionsForDay = _getSessionsForDay(_selectedDay);

    if (sessionsForDay.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Pas de cours ce jour',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final session = sessionsForDay[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildSessionCard(session),
              ),
            ),
          );
        },
        childCount: sessionsForDay.length,
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(ScheduleSession session) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.type,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  _getTimeSlot(session.period),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session.course,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.professor,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            if (!session.isOnline) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.room_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.room ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
