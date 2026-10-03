import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../controllers/lists_controller.dart';
import '../create_or_edit_list_sheet.dart';
import '../manage_lists_sheet.dart';

class ActiveListCard extends ConsumerWidget {
  final bool isTimerActive;

  const ActiveListCard({
    super.key,
    required this.isTimerActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemeColors(isTimerActive);
    final strings = ref.watch(appStringsProvider);
    final listsState = ref.watch(listsControllerProvider);
    final activeList = listsState.activeList;
    final hasLists = listsState.lists.isNotEmpty && activeList != null;

    final String listName = hasLists ? activeList.name : strings.listNoListsCreated;
    final String blockedText;
    if (hasLists) {
      if (activeList.isPhoneWideBan) {
        if (activeList.appNames.isEmpty) {
          blockedText = strings.listPhoneWideAllBlocked;
        } else if (activeList.appNames.length == 1) {
          blockedText = strings.listPhoneWideSingleAllowed;
        } else {
          blockedText = strings.listPhoneWideMultipleAllowed(activeList.appNames.length);
        }
      } else {
        if (activeList.appNames.isEmpty) {
          blockedText = strings.listStandardNoneBlocked;
        } else if (activeList.appNames.length == 1) {
          blockedText = strings.listStandardSingleBlocked;
        } else {
          blockedText = strings.listStandardMultipleBlocked(activeList.appNames.length);
        }
      }
    } else {
      blockedText = isTimerActive
          ? strings.listNoAppsBlocked
          : strings.listTapToCreateFirst;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTimerActive
              ? colors.accent.withValues(alpha: 0.35)
              : colors.cardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isTimerActive ? 0.05 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (!hasLists && !isTimerActive) {
              CreateOrEditListSheet.show(
                context,
                isTimerActive: isTimerActive,
              );
            } else {
              ManageListsSheet.show(
                context,
                isTimerActive: isTimerActive,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Icon representation
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    isTimerActive
                        ? Icons.lock_outline_rounded
                        : (hasLists
                            ? (activeList.isPhoneWideBan
                                ? Icons.phonelink_lock_rounded
                                : Icons.layers_outlined)
                            : Icons.playlist_add_rounded),
                    color: colors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Name of the List and saying how many apps it blocks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              listName,
                              style: TextStyle(
                                color: colors.text,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasLists && activeList.isPhoneWideBan) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.accent.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                strings.listPhoneWideBanBadge,
                                style: TextStyle(
                                  color: colors.accent,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                          if (isTimerActive) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: colors.accent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        blockedText,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Actions
                if (!hasLists) ...[
                  if (!isTimerActive)
                    ElevatedButton.icon(
                      onPressed: () {
                        CreateOrEditListSheet.show(
                          context,
                          isTimerActive: isTimerActive,
                        );
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: Text(
                        strings.listCreateButton,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.accentText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        visualDensity: VisualDensity.compact,
                        elevation: 0,
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () {
                        ManageListsSheet.show(
                          context,
                          isTimerActive: isTimerActive,
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 13),
                      label: Text(
                        strings.listViewButton,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.text,
                        side: BorderSide(
                          color: colors.accent.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ] else ...[
                  // Has lists
                  if (!isTimerActive) ...[
                    TextButton.icon(
                      onPressed: () {
                        CreateOrEditListSheet.show(
                          context,
                          isTimerActive: isTimerActive,
                        );
                      },
                      icon: const Icon(Icons.add, size: 15),
                      label: Text(
                        strings.listNewButton,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.accent,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Small button to Manage (or View if the timer is active) the Lists
                  OutlinedButton.icon(
                    onPressed: () {
                      ManageListsSheet.show(
                        context,
                        isTimerActive: isTimerActive,
                      );
                    },
                    icon: Icon(
                      isTimerActive
                          ? Icons.visibility_outlined
                          : Icons.tune_rounded,
                      size: 13,
                    ),
                    label: Text(
                      isTimerActive ? strings.listViewButton : strings.listManageButton,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text,
                      side: BorderSide(
                        color: isTimerActive
                            ? colors.accent.withValues(alpha: 0.5)
                            : colors.cardBorder,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
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
