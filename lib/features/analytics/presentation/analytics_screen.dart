import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Focus Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRange(),
              const SizedBox(height: 16),
              _buildMetricsGrid(),
              const SizedBox(height: 24),
              _buildWeeklyChartSection(),
              const SizedBox(height: 24),
              _buildRecentHistorySection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRange() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month, color: Color(0xFF10B981), size: 16),
          SizedBox(width: 8),
          Text(
            'This Week • Sep 22 - Sep 29',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: const [
        _MetricCard(
          title: 'Total Focus',
          value: '21h 45m',
          subtext: '+3.5h vs last week',
          icon: Icons.timer_outlined,
          color: Color(0xFF10B981),
        ),
        _MetricCard(
          title: 'Sessions',
          value: '28',
          subtext: '100% completed',
          icon: Icons.check_circle_outline,
          color: Color(0xFF6366F1),
        ),
        _MetricCard(
          title: 'Active Streak',
          value: '7 Days',
          subtext: 'Personal best: 14',
          icon: Icons.local_fire_department_rounded,
          color: Color(0xFFF59E0B),
        ),
        _MetricCard(
          title: 'Discipline Rate',
          value: '93%',
          subtext: 'Strike-free sessions',
          icon: Icons.shield_outlined,
          color: Color(0xFF06B6D4),
        ),
      ],
    );
  }

  Widget _buildWeeklyChartSection() {
    // Demo data for the weekly bar chart (hours per day)
    final weekData = [
      {'day': 'Mon', 'hours': 3.5, 'isToday': false},
      {'day': 'Tue', 'hours': 4.0, 'isToday': false},
      {'day': 'Wed', 'hours': 2.0, 'isToday': false},
      {'day': 'Thu', 'hours': 5.0, 'isToday': false},
      {'day': 'Fri', 'hours': 3.0, 'isToday': false},
      {'day': 'Sat', 'hours': 2.5, 'isToday': false},
      {'day': 'Sun', 'hours': 1.5, 'isToday': true},
    ];

    const double maxHours = 5.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Focus Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Avg: 3.1h / day',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekData.map((data) {
                final hours = data['hours'] as double;
                final day = data['day'] as String;
                final isToday = data['isToday'] as bool;
                final ratio = (hours / maxHours).clamp(0.08, 1.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${hours}h',
                      style: TextStyle(
                        color: isToday ? const Color(0xFF10B981) : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 105 * ratio,
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF10B981)
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: const Color(0xFF34D399), width: 1.5)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day,
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.white60,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistorySection() {
    final recentSessions = [
      {
        'title': 'Deep Exam Revision',
        'time': 'Today, 11:20 AM',
        'duration': '55 mins',
        'object': 'Laptop',
        'strikes': 0,
      },
      {
        'title': 'Problem Solving & Math',
        'time': 'Yesterday, 04:30 PM',
        'duration': '40 mins',
        'object': 'Coffee cup',
        'strikes': 1,
      },
      {
        'title': 'Literature Reading Block',
        'time': 'Yesterday, 09:15 AM',
        'duration': '30 mins',
        'object': 'Shoe',
        'strikes': 0,
      },
      {
        'title': 'Core Programming Practice',
        'time': 'Sep 27, 02:00 PM',
        'duration': '75 mins',
        'object': 'Computer keyboard',
        'strikes': 0,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Completed Sessions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentSessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final session = recentSessions[index];
            final strikes = session['strikes'] as int;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF10B981), size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${session['time']} • Unlocked with: ${session['object']}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session['duration'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        strikes == 0 ? 'Clean' : '$strikes strike',
                        style: TextStyle(
                          color: strikes == 0
                              ? const Color(0xFF10B981)
                              : Colors.orangeAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
