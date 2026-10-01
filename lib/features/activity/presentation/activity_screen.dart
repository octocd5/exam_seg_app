import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timer/controllers/timer_controller.dart';
import '../controllers/activity_controller.dart';
import '../models/activity_session.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityControllerProvider);
    final timerState = ref.watch(timerControllerProvider);

    final isTimerActive = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.verifying;

    // Construct an in-flight live session when the timer is active
    final ActivitySession? liveSession = isTimerActive
        ? ActivitySession(
            id: 'live-timer-session',
            title: 'Current Active Focus Block',
            startTime: timerState.startTime ??
                DateTime.now().subtract(Duration(seconds: timerState.elapsedSeconds)),
            endTime: DateTime.now(),
            durationSeconds: timerState.elapsedSeconds,
            targetObject: timerState.targetObject,
            strikes: timerState.interruptionCount,
            isLive: true,
          )
        : null;

    final dailyGroups = groupSessionsByDay(
      sessions: activityState.sessions,
      liveSession: liveSession,
    );

    // Compute key statistics
    final todayGroup = dailyGroups.firstWhere(
      (g) => g.isToday,
      orElse: () => DailyActivityGroup(
        date: DateTime.now(),
        sessions: const [],
        totalSeconds: 0,
        totalStrikes: 0,
      ),
    );

    final int todaySeconds = todayGroup.totalSeconds;
    final int todaySessionsCount = todayGroup.sessions.length;

    final int weeklyTotalSeconds = dailyGroups.take(7).fold<int>(
          0,
          (sum, g) => sum + g.totalSeconds,
        );

    final double weeklyAvgHours =
        dailyGroups.isEmpty ? 0 : (weeklyTotalSeconds / 3600.0) / 7.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Activity Info',
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: activityState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              )
            : RefreshIndicator(
                color: const Color(0xFF10B981),
                backgroundColor: const Color(0xFF1E293B),
                onRefresh: () async {
                  await ref.read(activityControllerProvider.notifier).loadSessions();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active tracking alert banner if timer is running
                      if (isTimerActive) ...[
                        _buildLiveActiveBanner(timerState),
                        const SizedBox(height: 16),
                      ],

                      _buildDateHeader(),
                      const SizedBox(height: 16),

                      // Metrics summary cards
                      _buildMetricsGrid(
                        todaySeconds: todaySeconds,
                        todaySessionsCount: todaySessionsCount,
                        weeklyTotalSeconds: weeklyTotalSeconds,
                        weeklyAvgHours: weeklyAvgHours,
                        isLiveActive: isTimerActive,
                      ),
                      const SizedBox(height: 24),

                      // 7-day visual bar chart
                      _buildWeeklyBarSection(dailyGroups, isTimerActive),
                      const SizedBox(height: 28),

                      // Day-by-Day Activity Feed (divided by each day)
                      _buildDailyFeedHeader(),
                      const SizedBox(height: 14),

                      _buildDailyGroupsList(dailyGroups),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDateHeader() {
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
          Icon(Icons.calendar_today, color: Color(0xFF10B981), size: 16),
          SizedBox(width: 8),
          Text(
            'Daily Activity Log • Real-time Tracking',
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

  Widget _buildLiveActiveBanner(TimerState timerState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.25),
            const Color(0xFF047857).withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer,
              color: Color(0xFF10B981),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'TIMER ACTIVELY TRACKING',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: 6),
                    _PulsingDot(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Current session: ${timerState.formattedElapsed}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'Actively logging into Today\'s activity tally',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid({
    required int todaySeconds,
    required int todaySessionsCount,
    required int weeklyTotalSeconds,
    required double weeklyAvgHours,
    required bool isLiveActive,
  }) {
    final todayFormatted = _formatDuration(todaySeconds);
    final weeklyFormatted = _formatDuration(weeklyTotalSeconds);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _MetricCard(
          title: 'Today\'s Focus',
          value: todayFormatted,
          subtext: isLiveActive ? 'Tracking actively now' : 'Logged today',
          icon: Icons.access_time_filled,
          color: const Color(0xFF10B981),
          showActivePulse: isLiveActive,
        ),
        _MetricCard(
          title: 'Today\'s Sessions',
          value: '$todaySessionsCount',
          subtext: todaySessionsCount == 1 ? '1 block recorded' : 'Blocks recorded',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF6366F1),
        ),
        _MetricCard(
          title: 'This Week Total',
          value: weeklyFormatted,
          subtext: 'Across last 7 days',
          icon: Icons.stacked_bar_chart,
          color: const Color(0xFFF59E0B),
        ),
        _MetricCard(
          title: 'Daily Average',
          value: '${weeklyAvgHours.toStringAsFixed(1)}h',
          subtext: 'Goal: 3.0h / day',
          icon: Icons.insights_rounded,
          color: const Color(0xFF06B6D4),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarSection(
    List<DailyActivityGroup> dailyGroups,
    bool isLiveActive,
  ) {
    // Generate the last 7 days in chronological order (oldest to today)
    final now = DateTime.now();
    final List<Map<String, dynamic>> barDays = [];
    double maxHours = 2.0;

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final group = dailyGroups.firstWhere(
        (g) =>
            g.date.year == targetDate.year &&
            g.date.month == targetDate.month &&
            g.date.day == targetDate.day,
        orElse: () => DailyActivityGroup(
          date: targetDate,
          sessions: const [],
          totalSeconds: 0,
          totalStrikes: 0,
        ),
      );

      final hours = group.hours;
      if (hours > maxHours) {
        maxHours = hours;
      }

      barDays.add({
        'day': group.dayLabel,
        'date': '${group.date.month}/${group.date.day}',
        'hours': hours,
        'isToday': group.isToday,
      });
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '7-Day Focus Distribution',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  if (isLiveActive)
                    const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: _PulsingDot(),
                    ),
                  Text(
                    isLiveActive ? 'Live Today' : 'Divided by day',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: barDays.map((data) {
                final hours = data['hours'] as double;
                final day = data['day'] as String;
                final isToday = data['isToday'] as bool;
                final ratio = maxHours <= 0 ? 0.08 : (hours / maxHours).clamp(0.08, 1.0);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        hours >= 1.0
                            ? '${hours.toStringAsFixed(1)}h'
                            : hours > 0
                                ? '${(hours * 60).round()}m'
                                : '0',
                        style: TextStyle(
                          color: isToday ? const Color(0xFF10B981) : Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 22,
                        height: 95 * ratio,
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF10B981)
                              : hours > 0
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF334155).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: isToday
                              ? Border.all(
                                  color: const Color(0xFF34D399),
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: isToday && hours > 0
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day,
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white60,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFeedHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daily Activity Breakdown',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          'Divided by Day',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGroupsList(List<DailyActivityGroup> dailyGroups) {
    if (dailyGroups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Text(
          'No activity recorded yet.\nStart the chronometer on the Timer tab to track focus time!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dailyGroups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final group = dailyGroups[index];
        return _DailyGroupCard(group: group);
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'About Focus Activity',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This screen actively logs the duration whenever the Focus Chronometer is running.\n\n'
          'All focus time is automatically divided by each calendar day, so you can inspect your exact study patterns and verify unlock history day by day.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got It',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalSeconds}s';
    }
  }
}

class _DailyGroupCard extends StatelessWidget {
  final DailyActivityGroup group;

  const _DailyGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final isToday = group.isToday;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? const Color(0xFF10B981).withValues(alpha: 0.6) : const Color(0xFF334155),
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFF172033),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isToday
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFF334155),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF10B981)
                            : const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        group.dayLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      group.formattedDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // Daily total duration pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF10B981).withValues(alpha: 0.18)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                          ? const Color(0xFF10B981)
                          : const Color(0xFF475569),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: isToday ? const Color(0xFF34D399) : Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        group.formattedTotalDuration,
                        style: TextStyle(
                          color: isToday ? const Color(0xFF34D399) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sessions list for this day
          if (group.sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No sessions recorded yet for ${group.dayLabel.toLowerCase()}.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: group.sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, sIndex) {
                final session = group.sessions[sIndex];
                return _SessionTile(session: session);
              },
            ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ActivitySession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final isLive = session.isLive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isLive
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? const Color(0xFF10B981)
              : const Color(0xFF334155).withValues(alpha: 0.7),
          width: isLive ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLive
                  ? const Color(0xFF10B981).withValues(alpha: 0.25)
                  : const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLive ? Icons.play_arrow_rounded : Icons.check,
              color: const Color(0xFF10B981),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Session description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        session.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isLive ? const Color(0xFF34D399) : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isLive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVE NOW',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${session.formattedTimeRange}${session.targetObject != null ? ' • Unlocked: ${session.targetObject}' : ''}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Duration & Strike pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.formattedDuration,
                style: TextStyle(
                  color: isLive ? const Color(0xFF34D399) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                session.strikes == 0 ? 'Clean' : '${session.strikes} strike',
                style: TextStyle(
                  color: session.strikes == 0
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
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;
  final bool showActivePulse;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
    this.showActivePulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showActivePulse
              ? color.withValues(alpha: 0.8)
              : const Color(0xFF334155),
          width: showActivePulse ? 1.5 : 1.0,
        ),
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
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showActivePulse) ...[
                    const SizedBox(width: 6),
                    const _PulsingDot(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  color: showActivePulse ? color : Colors.white38,
                  fontSize: 10,
                  fontWeight:
                      showActivePulse ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF10B981),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
