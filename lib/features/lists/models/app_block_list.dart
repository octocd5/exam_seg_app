class AppBlockList {
  final String id;
  final String name;
  final List<String> appNames;
  final DateTime createdAt;
  final bool isDefault;

  const AppBlockList({
    required this.id,
    required this.name,
    required this.appNames,
    required this.createdAt,
    this.isDefault = false,
  });

  int get appCount => appNames.length;

  String get blockedSummary {
    if (appNames.isEmpty) {
      return 'No apps blocked';
    } else if (appNames.length == 1) {
      return '1 app blocked';
    } else {
      return '${appNames.length} apps blocked';
    }
  }

  AppBlockList copyWith({
    String? id,
    String? name,
    List<String>? appNames,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return AppBlockList(
      id: id ?? this.id,
      name: name ?? this.name,
      appNames: appNames ?? this.appNames,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'appNames': appNames,
        'createdAt': createdAt.toIso8601String(),
        'isDefault': isDefault,
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
    );
  }
}
