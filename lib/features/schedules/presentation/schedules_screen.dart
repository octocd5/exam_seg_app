import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/schedules_controller.dart';
import '../models/schedule_item.dart';

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

  void _showAddScheduleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddScheduleModal(
        onSave: (newSchedule) {
          ref.read(schedulesControllerProvider.notifier).addSchedule(newSchedule);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schedulesControllerProvider);
    final notifier = ref.read(schedulesControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Focus Schedules',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Add Schedule',
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 28),
            onPressed: () => _showAddScheduleSheet(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Routines (${state.schedules.where((s) => s.isEnabled).length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddScheduleSheet(context, ref),
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF10B981)),
                    label: const Text(
                      'New Plan',
                      style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: state.schedules.isEmpty
                    ? _buildEmptyState(context, ref)
                    : ListView.separated(
                        itemCount: state.schedules.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final schedule = state.schedules[index];
                          return _ScheduleCard(
                            schedule: schedule,
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
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text(
          'Add Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddScheduleSheet(context, ref),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule_send_rounded, color: Color(0xFF10B981), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Scheduled sessions trigger automated focus locks & reminders so you never miss study time.',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          const Text(
            'No Active Schedules',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Create routines to automatically lock distractions during your planned focus hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _showAddScheduleSheet(context, ref),
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
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isEnabled
              ? const Color(0xFF10B981).withValues(alpha: 0.35)
              : const Color(0xFF334155),
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
                        color: schedule.isEnabled ? Colors.white : Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: schedule.isEnabled
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${schedule.durationMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: schedule.isEnabled
                              ? const Color(0xFF10B981)
                              : Colors.white54,
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
                    color: schedule.isEnabled ? Colors.white70 : Colors.white38,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 13,
                      color: schedule.isEnabled ? const Color(0xFF64748B) : Colors.white24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.daysSummary,
                      style: TextStyle(
                        fontSize: 12,
                        color: schedule.isEnabled ? const Color(0xFF94A3B8) : Colors.white24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: schedule.isEnabled,
            activeThumbColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFF334155),
            onChanged: (_) => onToggle(),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white38),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _AddScheduleModal extends StatefulWidget {
  final ValueChanged<ScheduleItem> onSave;

  const _AddScheduleModal({required this.onSave});

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
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              surface: Color(0xFF1E293B),
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
              const Text(
                'New Focus Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Session Title',
              labelStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
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
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time',
                                style: TextStyle(color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        const Icon(Icons.access_time_rounded, color: Color(0xFF10B981)),
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
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duration',
                          style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 2),
                      DropdownButton<int>(
                        value: _selectedDuration,
                        dropdownColor: const Color(0xFF1E293B),
                        underline: const SizedBox(),
                        isDense: true,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
          const Text('Repeat Days', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
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
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _save,
              child: const Text('Save Schedule',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
