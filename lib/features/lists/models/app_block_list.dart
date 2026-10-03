import '../../../core/localization/app_strings.dart';

class AppBlockList {
  final String id;
  final String name;
  final List<String> appNames;
  final DateTime createdAt;
  final bool isDefault;
  final bool isPhoneWideBan;

  const AppBlockList({
    required this.id,
    required this.name,
    required this.appNames,
    required this.createdAt,
    this.isDefault = false,
    this.isPhoneWideBan = false,
  });

  int get appCount => appNames.length;

  String get blockedSummary {
    if (isPhoneWideBan) {
      if (appNames.isEmpty) {
        return 'Phone-wide ban (all apps blocked)';
      } else if (appNames.length == 1) {
        return 'Phone-wide ban • 1 app allowed';
      } else {
        return 'Phone-wide ban • ${appNames.length} apps allowed';
      }
    } else {
      if (appNames.isEmpty) {
        return 'No apps blocked';
      } else if (appNames.length == 1) {
        return '1 app blocked';
      } else {
        return '${appNames.length} apps blocked';
      }
    }
  }

  String localizedBlockedSummary(AppStrings strings) {
    if (isPhoneWideBan) {
      if (appNames.isEmpty) {
        return strings.listPhoneWideAllBlocked;
      } else if (appNames.length == 1) {
        return strings.listPhoneWideSingleAllowed;
      } else {
        return strings.listPhoneWideMultipleAllowed(appNames.length);
      }
    } else {
      if (appNames.isEmpty) {
        return strings.listStandardNoneBlocked;
      } else if (appNames.length == 1) {
        return strings.listStandardSingleBlocked;
      } else {
        return strings.listStandardMultipleBlocked(appNames.length);
      }
    }
  }

  String get modeTitle =>
      isPhoneWideBan ? 'Phone-Wide Ban' : 'Blocklist';

  String localizedModeTitle(AppStrings strings) =>
      isPhoneWideBan ? strings.manageListsPhoneWideBadge : strings.manageListsBlocklistBadge;

  AppBlockList copyWith({
    String? id,
    String? name,
    List<String>? appNames,
    DateTime? createdAt,
    bool? isDefault,
    bool? isPhoneWideBan,
  }) {
    return AppBlockList(
      id: id ?? this.id,
      name: name ?? this.name,
      appNames: appNames ?? this.appNames,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
      isPhoneWideBan: isPhoneWideBan ?? this.isPhoneWideBan,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'appNames': appNames,
        'createdAt': createdAt.toIso8601String(),
        'isDefault': isDefault,
        'isPhoneWideBan': isPhoneWideBan,
      };

  factory AppBlockList.fromJson(Map<String, dynamic> json) {
    return AppBlockList(
      id: json['id'] as String,
      name: json['name'] as String,
      appNames: (json['appNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isDefault: json['isDefault'] as bool? ?? false,
      isPhoneWideBan: json['isPhoneWideBan'] as bool? ?? false,
    );
  }
}
