import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/lists_controller.dart';
import '../models/app_block_list.dart';
import '../models/app_catalog.dart';
import 'create_or_edit_list_sheet.dart';

class ManageListsSheet extends ConsumerWidget {
  final bool isTimerActive;

  const ManageListsSheet({
    super.key,
    required this.isTimerActive,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isTimerActive,
  }) {
    final colors = AppThemeColors(isTimerActive);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ManageListsSheet(isTimerActive: isTimerActive),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppBlockList list) {
    final colors = AppThemeColors(isTimerActive);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.cardBorder),
        ),
        title: Text(
          'Delete List?',
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${list.name}"?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final success = ref.read(listsControllerProvider.notifier).deleteList(
                    list.id,
                    isTimerActive: isTimerActive,
                  );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('List "${list.name}" deleted.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemeColors(isTimerActive);
    final listsState = ref.watch(listsControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isTimerActive
                            ? Icons.lock_clock_rounded
                            : Icons.view_list_rounded,
                        color: colors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTimerActive ? 'Active Block List' : 'Manage Lists',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        Text(
                          isTimerActive
                              ? 'View only • Timer is active'
                              : 'Select or edit block groups',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // If Timer is Active: show prominent Lock Notice
            if (isTimerActive) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LOCKED DURING SESSION',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lists cannot be changed or edited while the timer is running. Stop session to modify.',
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Content: List of lists or empty state
            if (listsState.lists.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.playlist_add_rounded, size: 48, color: colors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No Block Lists Created',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create your first list to choose which apps to block during focus sessions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: listsState.lists.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final list = listsState.lists[index];
                    final isActive = list.id == listsState.activeListId;

                    return _buildListCard(
                      context: context,
                      ref: ref,
                      list: list,
                      isActive: isActive,
                      colors: colors,
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Bottom Action Button
            if (!isTimerActive)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CreateOrEditListSheet.show(
                      context,
                      isTimerActive: isTimerActive,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.accentText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'Create New List',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required BuildContext context,
    required WidgetRef ref,
    required AppBlockList list,
    required bool isActive,
    required AppThemeColors colors,
  }) {
    final canEdit = !isTimerActive;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? colors.accent.withValues(alpha: 0.12)
            : colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? colors.accent.withValues(alpha: 0.6)
              : colors.cardBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canEdit
              ? () {
                  ref.read(listsControllerProvider.notifier).setActiveList(
                        list.id,
                        isTimerActive: isTimerActive,
                      );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Radio / Active Indicator
                    Icon(
                      isActive
                          ? (isTimerActive
                              ? Icons.lock
                              : Icons.radio_button_checked_rounded)
                          : Icons.radio_button_off_rounded,
                      color: isActive ? colors.accent : colors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  list.name,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.accent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isTimerActive ? 'ACTIVE & LOCKED' : 'ACTIVE',
                                    style: TextStyle(
                                      color: colors.accentText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            list.blockedSummary,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions if in standby mode
                    if (canEdit) ...[
                      IconButton(
                        tooltip: 'Edit List',
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                        onPressed: () {
                          CreateOrEditListSheet.show(
                            context,
                            existingList: list,
                            isTimerActive: isTimerActive,
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete List',
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: colors.textMuted,
                        ),
                        onPressed: () => _confirmDelete(context, ref, list),
                      ),
                    ] else if (isActive) ...[
                      // In view/locked mode: Show locked badge
                      Icon(
                        Icons.lock_outline_rounded,
                        color: colors.accent,
                        size: 20,
                      ),
                    ],
                  ],
                ),

                // Preview app pills
                if (list.appNames.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...list.appNames.take(5).map((app) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.cardBorder.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getAppIcon(app),
                                size: 12,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                app,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (list.appNames.length > 5)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.cardBorder.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${list.appNames.length - 5} more',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
