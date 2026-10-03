import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../timer/controllers/timer_controller.dart';
import '../controllers/schedules_controller.dart';
import '../models/schedule_item.dart';

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

  void _showAddScheduleSheet(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors colors,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddScheduleModal(
        colors: colors,
        onSave: (newSchedule) {
          ref.read(schedulesControllerProvider.notifier).addSchedule(newSchedule);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final isTimerActive = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.verifying;
    final colors = AppThemeColors(isTimerActive);

    final state = ref.watch(schedulesControllerProvider);
    final notifier = ref.read(schedulesControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        actions: [
          IconButton(
            tooltip: 'Add Schedule',
            icon: Icon(Icons.add_circle_outline, color: colors.accent, size: 28),
            onPressed: () => _showAddScheduleSheet(context, ref, colors),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(colors),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Routines (${state.schedules.where((s) => s.isEnabled).length})',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddScheduleSheet(context, ref, colors),
                    icon: Icon(Icons.add, size: 18, color: colors.accent),
                    label: Text(
                      'New Plan',
                      style: TextStyle(color: colors.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: state.schedules.isEmpty
                    ? _buildEmptyState(context, ref, colors)
                    : ListView.separated(
                        itemCount: state.schedules.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final schedule = state.schedules[index];
                          return _ScheduleCard(
                            schedule: schedule,
                            colors: colors,
                            onToggle: () => notifier.toggleSchedule(schedule.id),
                            onDelete: () => notifier.deleteSchedule(schedule.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.accent,
        foregroundColor: colors.accentText,
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text(
          'Add Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddScheduleSheet(context, ref, colors),
      ),
    );
  }

  Widget _buildInfoBanner(AppThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_send_rounded, color: colors.accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Scheduled sessions trigger automated focus locks & reminders so you never miss study time.',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: colors.textMuted),
          const SizedBox(height: 14),
          Text(
            'No Active Schedules',
            style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Create routines to automatically lock distractions during your planned focus hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.accentText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _showAddScheduleSheet(context, ref, colors),
            icon: const Icon(Icons.add),
            label: const Text('Create First Schedule'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem schedule;
  final AppThemeColors colors;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.colors,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isEnabled
              ? colors.accent.withValues(alpha: 0.45)
              : colors.cardBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      schedule.formattedTime,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: schedule.isEnabled ? colors.text : colors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: schedule.isEnabled
                            ? colors.accent.withValues(alpha: 0.18)
                            : colors.cardBorder.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${schedule.durationMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: schedule.isEnabled
                              ? colors.accent
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  schedule.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: schedule.isEnabled ? colors.text : colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 13,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.daysSummary,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: schedule.isEnabled,
            activeThumbColor: colors.accent,
            activeTrackColor: colors.accent.withValues(alpha: 0.35),
            inactiveThumbColor: colors.cardBorder,
            inactiveTrackColor: colors.cardBorder.withValues(alpha: 0.4),
            onChanged: (_) => onToggle(),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: Icon(Icons.delete_outline, size: 20, color: colors.textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _AddScheduleModal extends StatefulWidget {
  final AppThemeColors colors;
  final ValueChanged<ScheduleItem> onSave;

  const _AddScheduleModal({
    required this.colors,
    required this.onSave,
  });

  @override
  State<_AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<_AddScheduleModal> {
  final _titleController = TextEditingController(text: 'Focus Session');
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedDuration = 45;
  final List<int> _selectedDays = [1, 2, 3, 4, 5];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final colors = widget.colors;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final currentTheme = Theme.of(context);
        return Theme(
          data: currentTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.accent,
              brightness: colors.isTimerActive ? Brightness.light : Brightness.dark,
              surface: colors.cardBackground,
              primary: colors.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newSchedule = ScheduleItem(
      id: 'sched-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      time: _selectedTime,
      durationMinutes: _selectedDuration,
      repeatDays: List.from(_selectedDays),
      isEnabled: true,
    );

    widget.onSave(newSchedule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Focus Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              labelText: 'Session Title',
              labelStyle: TextStyle(color: colors.textSecondary),
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(color: colors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                color: colors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.access_time_rounded, color: colors.accent),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(color: colors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      DropdownButton<int>(
                        value: _selectedDuration,
                        dropdownColor: colors.cardBackground,
                        underline: const SizedBox(),
                        isDense: true,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        items: const [
                          DropdownMenuItem(value: 15, child: Text('15 min')),
                          DropdownMenuItem(value: 25, child: Text('25 min')),
                          DropdownMenuItem(value: 45, child: Text('45 min')),
                          DropdownMenuItem(value: 60, child: Text('60 min')),
                          DropdownMenuItem(value: 90, child: Text('90 min')),
                          DropdownMenuItem(value: 120, child: Text('120 min')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDuration = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Repeat Days',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _selectedDays.contains(dayNum);
              return GestureDetector(
                onTap: () => _toggleDay(dayNum),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accent : colors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colors.accent : colors.cardBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      color: isSelected ? colors.accentText : colors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.accentText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _save,
              child: const Text(
                'Save Schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
