import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/native_bridge/blocker_channel.dart';
import '../controllers/lists_controller.dart';
import '../models/app_block_list.dart';
import '../models/app_catalog.dart';

class CreateOrEditListSheet extends ConsumerStatefulWidget {
  final AppBlockList? existingList;
  final bool isTimerActive;

  const CreateOrEditListSheet({
    super.key,
    this.existingList,
    required this.isTimerActive,
  });

  static Future<void> show(
    BuildContext context, {
    AppBlockList? existingList,
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
      builder: (context) => CreateOrEditListSheet(
        existingList: existingList,
        isTimerActive: isTimerActive,
      ),
    );
  }

  @override
  ConsumerState<CreateOrEditListSheet> createState() =>
      _CreateOrEditListSheetState();
}

class _CreateOrEditListSheetState extends ConsumerState<CreateOrEditListSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;
  late final TextEditingController _customAppController;
  late final Set<String> _selectedApps;

  List<InstalledApp> _installedApps = [];
  bool _isLoadingApps = true;
  String _selectedFilter = 'All'; // 'All', 'User Apps', 'Selected'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingList?.name ?? '',
    );
    _searchController = TextEditingController();
    _customAppController = TextEditingController();
    _selectedApps = Set<String>.from(widget.existingList?.appNames ?? []);

    _loadDeviceApps();
  }

  Future<void> _loadDeviceApps() async {
    final apps = await BlockerChannel.getInstalledApps();
    if (!mounted) return;

    setState(() {
      if (apps.isNotEmpty) {
        _installedApps = apps;
      } else {
        // Fallback for simulators or environments where native listing is unavailable
        _installedApps = kDefaultAppCatalog
            .map(
              (c) => InstalledApp(
                name: c.name,
                packageName: 'com.distraction.${c.name.toLowerCase().replaceAll(' ', '')}',
                isSystemApp: false,
              ),
            )
            .toList();
      }
      _isLoadingApps = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _customAppController.dispose();
    super.dispose();
  }

  void _toggleApp(String appName) {
    if (widget.isTimerActive) return;
    setState(() {
      if (_selectedApps.contains(appName)) {
        _selectedApps.remove(appName);
      } else {
        _selectedApps.add(appName);
      }
    });
  }

  void _addCustomApp() {
    if (widget.isTimerActive) return;
    final name = _customAppController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _selectedApps.add(name);
      // Also add to installed list if not already present
      if (!_installedApps.any((a) => a.name.toLowerCase() == name.toLowerCase())) {
        _installedApps.insert(
          0,
          InstalledApp(name: name, packageName: 'custom.user.app'),
        );
      }
      _customAppController.clear();
    });
  }

  void _selectAll(List<InstalledApp> apps) {
    if (widget.isTimerActive) return;
    setState(() {
      for (final app in apps) {
        _selectedApps.add(app.name);
      }
    });
  }

  void _deselectAll() {
    if (widget.isTimerActive) return;
    setState(() {
      _selectedApps.clear();
    });
  }

  void _saveList() {
    if (widget.isTimerActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create or edit lists while the timer is active!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for the list'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final controller = ref.read(listsControllerProvider.notifier);
    final isEditing = widget.existingList != null;

    if (isEditing) {
      final updated = widget.existingList!.copyWith(
        name: name,
        appNames: _selectedApps.toList(),
      );
      controller.updateList(updated, isTimerActive: widget.isTimerActive);
    } else {
      controller.createList(
        name: name,
        appNames: _selectedApps.toList(),
        isTimerActive: widget.isTimerActive,
      );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'List "$name" updated!' : 'List "$name" created!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors(widget.isTimerActive);
    final isEditing = widget.existingList != null;

    // Filter apps
    final filterOptions = ['All', 'User Apps', 'Selected'];
    final filteredApps = _installedApps.where((app) {
      final matchesFilter = switch (_selectedFilter) {
        'User Apps' => !app.isSystemApp,
        'Selected' => _selectedApps.contains(app.name),
        _ => true,
      };

      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          app.name.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
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
                        isEditing ? Icons.edit_note_rounded : Icons.playlist_add_rounded,
                        color: colors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit List' : 'Create New List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
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

            // List Name input field
            Text(
              'LIST NAME',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              enabled: !widget.isTimerActive,
              style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Enter list name (e.g. Study, Work)...',
                hintStyle: TextStyle(color: colors.textMuted),
                filled: true,
                fillColor: colors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.accent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Apps selection heading & Select All / Clear
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INSTALLED APPS (${_selectedApps.length} selected)',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                if (!_isLoadingApps)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _selectAll(filteredApps),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Select All',
                          style: TextStyle(color: colors.accent, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: _deselectAll,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(color: colors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: colors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search installed apps...',
                hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
                filled: true,
                fillColor: colors.background,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  final label = switch (filter) {
                    'All' => 'All (${_installedApps.length})',
                    'Selected' => 'Selected (${_selectedApps.length})',
                    _ => filter,
                  };

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colors.accentText : colors.textSecondary,
                    ),
                    selectedColor: colors.accent,
                    backgroundColor: colors.background,
                    side: BorderSide(
                      color: isSelected ? colors.accent : colors.cardBorder,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Installed apps list or loading state
            Expanded(
              child: _isLoadingApps
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(colors.accent),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pulling installed apps from phone...',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : (filteredApps.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: colors.textMuted,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No matching apps found',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredApps.length + 1,
                          itemBuilder: (context, index) {
                            if (index == filteredApps.length) {
                              // Custom App input at bottom
                              return Container(
                                margin: const EdgeInsets.only(top: 10, bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: colors.accent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _customAppController,
                                        style: TextStyle(
                                          color: colors.text,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Add custom app name...',
                                          hintStyle: TextStyle(
                                            color: colors.textMuted,
                                            fontSize: 13,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        onSubmitted: (_) => _addCustomApp(),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _addCustomApp,
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Text(
                                        'Add',
                                        style: TextStyle(
                                          color: colors.accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final app = filteredApps[index];
                            final isSelected = _selectedApps.contains(app.name);

                            return _buildAppTile(
                              app: app,
                              isSelected: isSelected,
                              colors: colors,
                            );
                          },
                        )),
            ),

            // Save List Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.accentText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: Icon(
                  isEditing ? Icons.check_rounded : Icons.save_rounded,
                  size: 20,
                ),
                label: Text(
                  isEditing ? 'Save Changes' : 'Create List',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTile({
    required InstalledApp app,
    required bool isSelected,
    required AppThemeColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.accent.withValues(alpha: 0.12)
            : colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.5)
              : colors.cardBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.accent.withValues(alpha: 0.2)
                  : colors.cardBorder.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: app.iconBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      app.iconBytes!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    getAppIcon(app.name),
                    size: 20,
                    color: isSelected ? colors.accent : colors.textSecondary,
                  ),
          ),
          title: Text(
            app.name,
            style: TextStyle(
              color: colors.text,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            app.packageName,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: widget.isTimerActive ? null : (_) => _toggleApp(app.name),
            activeColor: colors.accent,
            checkColor: colors.accentText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: () => _toggleApp(app.name),
        ),
      ),
    );
  }
}
