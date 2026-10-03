import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
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
    final colors = AppThemeColors(isTimerActive);

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
            strikes: 0,
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
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        actions: [
          IconButton(
            tooltip: 'Activity Info',
            icon: Icon(Icons.info_outline, color: colors.textSecondary),
            onPressed: () => _showInfoDialog(context, colors),
          ),
        ],
      ),
      body: SafeArea(
        child: activityState.isLoading
            ? Center(
                child: CircularProgressIndicator(color: colors.accent),
              )
            : RefreshIndicator(
                color: colors.accent,
                backgroundColor: colors.cardBackground,
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
                        _buildLiveActiveBanner(timerState, colors),
                        const SizedBox(height: 16),
                      ],

                      _buildDateHeader(colors),
                      const SizedBox(height: 16),

                      // Metrics summary cards
                      _buildMetricsGrid(
                        colors: colors,
                        todaySeconds: todaySeconds,
                        todaySessionsCount: todaySessionsCount,
                        weeklyTotalSeconds: weeklyTotalSeconds,
                        weeklyAvgHours: weeklyAvgHours,
                        isLiveActive: isTimerActive,
                      ),
                      const SizedBox(height: 24),

                      // 7-day visual bar chart
                      _buildWeeklyBarSection(dailyGroups, isTimerActive, colors),
                      const SizedBox(height: 28),

                      // Day-by-Day Activity Feed (divided by each day)
                      _buildDailyFeedHeader(colors),
                      const SizedBox(height: 14),

                      _buildDailyGroupsList(dailyGroups, colors),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDateHeader(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, color: colors.accent, size: 16),
          const SizedBox(width: 8),
          Text(
            'Daily Activity Log • Real-time Tracking',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActiveBanner(TimerState timerState, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.22),
            colors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.15),
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
              color: colors.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer,
              color: colors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'TIMER ACTIVELY TRACKING',
                      style: TextStyle(
                        color: colors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _PulsingDot(color: colors.accent),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Current session: ${timerState.formattedElapsed}',
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'Actively logging into Today\'s activity tally',
                  style: TextStyle(
                    color: colors.textSecondary,
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
    required AppThemeColors colors,
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
          color: colors.accent,
          colors: colors,
          showActivePulse: isLiveActive,
        ),
        _MetricCard(
          title: 'Today\'s Sessions',
          value: '$todaySessionsCount',
          subtext: todaySessionsCount == 1 ? '1 block recorded' : 'Blocks recorded',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF6366F1),
          colors: colors,
        ),
        _MetricCard(
          title: 'This Week Total',
          value: weeklyFormatted,
          subtext: 'Across last 7 days',
          icon: Icons.stacked_bar_chart,
          color: kTimerStandbyButtonColor,
          colors: colors,
        ),
        _MetricCard(
          title: 'Daily Average',
          value: '${weeklyAvgHours.toStringAsFixed(1)}h',
          subtext: '7-day daily average',
          icon: Icons.insights_rounded,
          color: const Color(0xFF06B6D4),
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildWeeklyBarSection(
    List<DailyActivityGroup> dailyGroups,
    bool isLiveActive,
    AppThemeColors colors,
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
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Focus Distribution',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  if (isLiveActive)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: _PulsingDot(color: colors.accent),
                    ),
                  Text(
                    isLiveActive ? 'Live Today' : 'Divided by day',
                    style: TextStyle(
                      color: colors.accent,
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

                final unselectedBarColor = colors.isTimerActive
                    ? (hours > 0 ? const Color(0xFFC0BAB2) : const Color(0xFFE2DDD7))
                    : (hours > 0 ? const Color(0xFF474440) : const Color(0xFF33312E));

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
                          color: isToday ? colors.accent : colors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 22,
                        height: 95 * ratio,
                        decoration: BoxDecoration(
                          color: isToday ? colors.accent : unselectedBarColor,
                          borderRadius: BorderRadius.circular(6),
                          border: isToday
                              ? Border.all(
                                  color: colors.accent,
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: isToday && hours > 0
                              ? [
                                  BoxShadow(
                                    color: colors.accent.withValues(alpha: 0.4),
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
                          color: isToday ? colors.text : colors.textSecondary,
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

  Widget _buildDailyFeedHeader(AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daily Activity Breakdown',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          'Divided by Day',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGroupsList(List<DailyActivityGroup> dailyGroups, AppThemeColors colors) {
    if (dailyGroups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Text(
          'No activity recorded yet.\nStart the chronometer on the Timer tab to track focus time!',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, height: 1.5),
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
        return _DailyGroupCard(group: group, colors: colors);
      },
    );
  }

  void _showInfoDialog(BuildContext context, AppThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'About Focus Activity',
          style: TextStyle(color: colors.text),
        ),
        content: Text(
          'This screen actively logs the duration whenever the Focus Chronometer is running.\n\n'
          'All focus time is automatically divided by each calendar day, so you can inspect your exact study patterns and verify unlock history day by day.',
          style: TextStyle(color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got It',
              style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold),
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
  final AppThemeColors colors;

  const _DailyGroupCard({
    required this.group,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = group.isToday;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? colors.accent.withValues(alpha: 0.6)
              : colors.cardBorder,
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
                  ? colors.accent.withValues(alpha: 0.12)
                  : (colors.isTimerActive ? const Color(0xFFE4DFD8) : const Color(0xFF22211E)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isToday
                      ? colors.accent.withValues(alpha: 0.25)
                      : colors.cardBorder,
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
                            ? colors.accent
                            : (colors.isTimerActive ? const Color(0xFFC8C2BA) : const Color(0xFF383633)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        group.dayLabel,
                        style: TextStyle(
                          color: isToday ? colors.accentText : colors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      group.formattedDate,
                      style: TextStyle(
                        color: colors.textSecondary,
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
                        ? colors.accent.withValues(alpha: 0.18)
                        : colors.cardBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday ? colors.accent : colors.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: isToday ? colors.accent : colors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        group.formattedTotalDuration,
                        style: TextStyle(
                          color: isToday ? colors.accent : colors.text,
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
                    color: colors.textMuted,
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
                return _SessionTile(session: session, colors: colors);
              },
            ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ActivitySession session;
  final AppThemeColors colors;

  const _SessionTile({
    required this.session,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = session.isLive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isLive
            ? colors.accent.withValues(alpha: 0.12)
            : colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? colors.accent
              : colors.cardBorder,
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
                  ? colors.accent.withValues(alpha: 0.25)
                  : colors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLive ? Icons.play_arrow_rounded : Icons.check,
              color: colors.accent,
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
                          color: isLive ? colors.accent : colors.text,
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
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ACTIVE NOW',
                          style: TextStyle(
                            color: colors.accentText,
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
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Duration pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.formattedDuration,
                style: TextStyle(
                  color: isLive ? colors.accent : colors.text,
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
                      ? colors.accent
                      : const Color(0xFFEF4444),
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
  final AppThemeColors colors;
  final bool showActivePulse;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
    required this.colors,
    this.showActivePulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showActivePulse
              ? color.withValues(alpha: 0.8)
              : colors.cardBorder,
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
                  color: colors.textSecondary,
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
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showActivePulse) ...[
                    const SizedBox(width: 6),
                    _PulsingDot(color: colors.accent),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  color: showActivePulse ? color : colors.textMuted,
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
  final Color color;

  const _PulsingDot({this.color = const Color(0xFFC4BDDD)});

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
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
