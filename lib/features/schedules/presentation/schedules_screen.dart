import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../lists/controllers/lists_controller.dart';
import '../../lists/models/app_block_list.dart';
import '../../timer/controllers/timer_controller.dart';
import '../controllers/schedules_controller.dart';
import '../models/schedule_item.dart';

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

  void _showScheduleSheet(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors colors,
    AppStrings strings, {
    ScheduleItem? scheduleToEdit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddOrEditScheduleModal(
        colors: colors,
        strings: strings,
        scheduleToEdit: scheduleToEdit,
        onSave: (savedSchedule) {
          if (scheduleToEdit != null) {
            ref.read(schedulesControllerProvider.notifier).updateSchedule(savedSchedule);
          } else {
            ref.read(schedulesControllerProvider.notifier).addSchedule(savedSchedule);
          }
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ScheduleItem schedule,
    AppThemeColors colors,
    AppStrings strings,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.cardBorder),
        ),
        title: Text(
          strings.schedulesDeleteTitle,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        content: Text(
          strings.schedulesDeleteContent(schedule.title),
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              strings.schedulesCancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(schedulesControllerProvider.notifier).deleteSchedule(schedule.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.schedulesDeletedSnackbar(schedule.title)),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(strings.schedulesDelete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final isTimerActive = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.verifying;
    final colors = AppThemeColors(isTimerActive);
    final strings = ref.watch(appStringsProvider);

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
            tooltip: strings.schedulesAddSchedule,
            icon: Icon(Icons.add_circle_outline, color: colors.accent, size: 28),
            onPressed: () => _showScheduleSheet(context, ref, colors, strings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(colors, strings),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.schedulesActiveRoutines(
                      state.schedules.where((s) => s.isEnabled).length,
                    ),
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showScheduleSheet(context, ref, colors, strings),
                    icon: Icon(Icons.add, size: 18, color: colors.accent),
                    label: Text(
                      strings.schedulesNewPlan,
                      style: TextStyle(color: colors.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: state.schedules.isEmpty
                    ? _buildEmptyState(context, ref, colors, strings)
                    : ListView.separated(
                        itemCount: state.schedules.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final schedule = state.schedules[index];
                          return _ScheduleCard(
                            schedule: schedule,
                            colors: colors,
                            strings: strings,
                            onToggle: () => notifier.toggleSchedule(schedule.id),
                            onEdit: () => _showScheduleSheet(
                              context,
                              ref,
                              colors,
                              strings,
                              scheduleToEdit: schedule,
                            ),
                            onDelete: () => _confirmDelete(context, ref, schedule, colors, strings),
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
        label: Text(
          strings.schedulesAddSchedule,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showScheduleSheet(context, ref, colors, strings),
      ),
    );
  }

  Widget _buildInfoBanner(AppThemeColors colors, AppStrings strings) {
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
              strings.schedulesBannerInfo,
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

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors colors,
    AppStrings strings,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: colors.textMuted),
          const SizedBox(height: 14),
          Text(
            strings.schedulesEmptyTitle,
            style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            strings.schedulesEmptySubtitle,
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
            onPressed: () => _showScheduleSheet(context, ref, colors, strings),
            icon: const Icon(Icons.add),
            label: Text(strings.schedulesCreateFirst),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  final ScheduleItem schedule;
  final AppThemeColors colors;
  final AppStrings strings;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.colors,
    required this.strings,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsState = ref.watch(listsControllerProvider);
    AppBlockList? assignedList;
    if (schedule.listId != null) {
      try {
        assignedList = listsState.lists.firstWhere((l) => l.id == schedule.listId);
      } catch (_) {
        assignedList = null;
      }
    }

    final String listDisplayName = assignedList?.name ??
        schedule.listName ??
        strings.schedulesCurrentActiveList;
    final bool isPhoneWide = assignedList?.isPhoneWideBan ?? false;

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        schedule.formattedTime,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: schedule.isEnabled ? colors.text : colors.textMuted,
                        ),
                      ),
                      if (schedule.endTime != null) ...[
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: colors.textMuted,
                        ),
                        Text(
                          schedule.formattedEndTime!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: schedule.isEnabled ? colors.text : colors.textMuted,
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: schedule.isEnabled
                              ? colors.accent.withValues(alpha: 0.18)
                              : colors.cardBorder.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              schedule.endTime != null
                                  ? Icons.access_time_rounded
                                  : Icons.stop_circle_outlined,
                              size: 12,
                              color: schedule.isEnabled
                                  ? colors.accent
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              schedule.endTime != null
                                  ? strings.schedulesEndsAt(schedule.formattedEndTime!)
                                  : strings.schedulesUntilStopped,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: schedule.isEnabled
                                    ? colors.accent
                                    : colors.textSecondary,
                              ),
                            ),
                          ],
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
                  const SizedBox(height: 5),
                  // Repeat days row
                  Row(
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 13,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.localizedDaysSummary(strings),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Assigned Block List row
                  Row(
                    children: [
                      Icon(
                        isPhoneWide
                            ? Icons.phone_android_rounded
                            : Icons.shield_outlined,
                        size: 13,
                        color: schedule.isEnabled ? colors.accent : colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          listDisplayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: schedule.isEnabled ? colors.accent : colors.textMuted,
                          ),
                        ),
                      ),
                      if (assignedList != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: (isPhoneWide ? colors.accent : colors.cardBorder)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPhoneWide
                                ? strings.manageListsPhoneWideBadge
                                : strings.listStandardMultipleBlocked(assignedList.appCount),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isPhoneWide ? colors.accent : colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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
              tooltip: strings.manageListsEditButton,
              icon: Icon(Icons.edit_outlined, size: 19, color: colors.textMuted),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: strings.schedulesDelete,
              icon: Icon(Icons.delete_outline, size: 20, color: colors.textMuted),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOrEditScheduleModal extends ConsumerStatefulWidget {
  final AppThemeColors colors;
  final AppStrings strings;
  final ScheduleItem? scheduleToEdit;
  final ValueChanged<ScheduleItem> onSave;

  const _AddOrEditScheduleModal({
    required this.colors,
    required this.strings,
    this.scheduleToEdit,
    required this.onSave,
  });

  @override
  ConsumerState<_AddOrEditScheduleModal> createState() =>
      _AddOrEditScheduleModalState();
}

class _AddOrEditScheduleModalState
    extends ConsumerState<_AddOrEditScheduleModal> {
  late final TextEditingController _titleController;
  late TimeOfDay _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool _hasEndTime = true;
  late List<int> _selectedDays;
  String? _selectedListId;
  String? _selectedListName;

  @override
  void initState() {
    super.initState();
    final edit = widget.scheduleToEdit;
    if (edit != null) {
      _titleController = TextEditingController(text: edit.title);
      _selectedStartTime = edit.time;
      _selectedEndTime = edit.endTime;
      _hasEndTime = edit.endTime != null;
      _selectedDays = List.from(edit.repeatDays);
      _selectedListId = edit.listId;
      _selectedListName = edit.listName;
    } else {
      _titleController =
          TextEditingController(text: widget.strings.schedulesModalTitle);
      _selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
      _selectedEndTime = const TimeOfDay(hour: 10, minute: 0);
      _hasEndTime = true;
      _selectedDays = [1, 2, 3, 4, 5];
      // Default to currently active list if one exists
      final listsState = ref.read(listsControllerProvider);
      if (listsState.lists.isNotEmpty) {
        final active = listsState.activeList;
        _selectedListId = active?.id ?? listsState.lists.first.id;
        _selectedListName = active?.name ?? listsState.lists.first.name;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final colors = widget.colors;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
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
      setState(() {
        _selectedStartTime = picked;
        // If end time is not set or earlier, advance it
        if (_hasEndTime && _selectedEndTime == null) {
          _selectedEndTime = TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final colors = widget.colors;
    final initial = _selectedEndTime ??
        TimeOfDay(
          hour: (_selectedStartTime.hour + 1) % 24,
          minute: _selectedStartTime.minute,
        );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
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
      setState(() {
        _selectedEndTime = picked;
        _hasEndTime = true;
      });
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
      id: widget.scheduleToEdit?.id ??
          'sched-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      time: _selectedStartTime,
      endTime: _hasEndTime
          ? (_selectedEndTime ??
              TimeOfDay(
                hour: (_selectedStartTime.hour + 1) % 24,
                minute: _selectedStartTime.minute,
              ))
          : null,
      repeatDays: List.from(_selectedDays),
      isEnabled: widget.scheduleToEdit?.isEnabled ?? true,
      listId: _selectedListId,
      listName: _selectedListName,
    );

    widget.onSave(newSchedule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final strings = widget.strings;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dayLabels = strings.scheduleDayInitials;
    final listsState = ref.watch(listsControllerProvider);

    final bool listExists = _selectedListId != null &&
        listsState.lists.any((l) => l.id == _selectedListId);
    final String? dropdownValue = listExists ? _selectedListId : null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.scheduleToEdit != null
                      ? strings.schedulesEditModalTitle
                      : strings.schedulesModalTitle,
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
                labelText: strings.schedulesRoutineName,
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
            // Schedule End Mode Toggle (Set End Time vs End When Stopped)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _hasEndTime = true;
                        _selectedEndTime ??= TimeOfDay(
                          hour: (_selectedStartTime.hour + 1) % 24,
                          minute: _selectedStartTime.minute,
                        );
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _hasEndTime
                            ? colors.accent.withValues(alpha: 0.18)
                            : colors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _hasEndTime ? colors.accent : colors.cardBorder,
                          width: _hasEndTime ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: _hasEndTime ? colors.accent : colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              strings.schedulesSetEndTime,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _hasEndTime ? colors.accent : colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _hasEndTime = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                      decoration: BoxDecoration(
                        color: !_hasEndTime
                            ? colors.accent.withValues(alpha: 0.18)
                            : colors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: !_hasEndTime ? colors.accent : colors.cardBorder,
                          width: !_hasEndTime ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_circle_outlined,
                            size: 15,
                            color: !_hasEndTime ? colors.accent : colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              strings.schedulesEndsWhenStopped,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_hasEndTime ? colors.accent : colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Start Time & End Time row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStartTime,
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
                                strings.schedulesStartTime,
                                style: TextStyle(color: colors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedStartTime.format(context),
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
                  child: _hasEndTime
                      ? InkWell(
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      strings.schedulesEndTime,
                                      style: TextStyle(
                                        color: colors.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (_selectedEndTime ??
                                              TimeOfDay(
                                                hour: (_selectedStartTime.hour + 1) % 24,
                                                minute: _selectedStartTime.minute,
                                              ))
                                          .format(context),
                                      style: TextStyle(
                                        color: colors.text,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.alarm_on_rounded, color: colors.accent),
                              ],
                            ),
                          ),
                        )
                      : Container(
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
                                    strings.schedulesEndTime,
                                    style: TextStyle(color: colors.textSecondary, fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    strings.schedulesUntilStopped,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.stop_circle_outlined, color: colors.textMuted),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Block List Picker Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: colors.accent),
                      const SizedBox(width: 6),
                      Text(
                        strings.schedulesAssignedList,
                        style: TextStyle(color: colors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (listsState.lists.isEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: colors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.schedulesNoListsCreated,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    DropdownButton<String?>(
                      value: dropdownValue,
                      dropdownColor: colors.cardBackground,
                      underline: const SizedBox(),
                      isExpanded: true,
                      isDense: true,
                      icon: Icon(Icons.arrow_drop_down_rounded, color: colors.accent),
                      style: TextStyle(
                        color: colors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.layers_outlined, size: 16, color: colors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.schedulesCurrentActiveList,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...listsState.lists.map((list) {
                          return DropdownMenuItem<String?>(
                            value: list.id,
                            child: Row(
                              children: [
                                Icon(
                                  list.isPhoneWideBan
                                      ? Icons.phone_android_rounded
                                      : Icons.shield_outlined,
                                  size: 16,
                                  color: colors.accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    list.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.text,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (list.isPhoneWideBan ? colors.accent : colors.cardBorder)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: (list.isPhoneWideBan ? colors.accent : colors.cardBorder)
                                          .withValues(alpha: 0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    list.isPhoneWideBan
                                        ? strings.manageListsPhoneWideBadge
                                        : strings.listStandardMultipleBlocked(list.appCount),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: list.isPhoneWideBan ? colors.accent : colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (selectedId) {
                        setState(() {
                          _selectedListId = selectedId;
                          if (selectedId != null) {
                            final match = listsState.lists.where((l) => l.id == selectedId);
                            _selectedListName = match.isNotEmpty ? match.first.name : null;
                          } else {
                            _selectedListName = null;
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.schedulesActiveDays,
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
                child: Text(
                  strings.schedulesSave,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

