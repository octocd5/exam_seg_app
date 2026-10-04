import 'package:flutter/material.dart';

abstract class AppStrings {
  // Navigation
  String get navTimer;
  String get navSchedules;
  String get navActivity;
  String get navSettings;

  // Timer Screen
  String get timerTodaysFocusTime;
  String get timerStartChronometer;
  String get timerStopAndScan;
  String timerPhotographObject(String object);
  String get timerTrackingTime;
  String get timerVerificationPending;
  String get timerRequestPermissionsTooltip;
  String get timerPermissionsActive;
  String get timerPermissionsDenied;

  // Active List Card
  String get listNoListsCreated;
  String get listNoAppsBlocked;
  String get listTapToCreateFirst;
  String get listPhoneWideBanBadge;
  String get listCreateButton;
  String get listViewButton;
  String get listNewButton;
  String get listManageButton;
  String get listPhoneWideAllBlocked;
  String get listPhoneWideSingleAllowed;
  String listPhoneWideMultipleAllowed(int count);
  String get listStandardNoneBlocked;
  String get listStandardSingleBlocked;
  String listStandardMultipleBlocked(int count);

  // Activity Screen
  String get activityHeaderBadge;
  String get activityTimerActivelyTracking;
  String activityCurrentSession(String time);
  String get activityLoggingIntoToday;
  String get activityTodaysFocus;
  String get activityTrackingActively;
  String get activityLoggedToday;
  String get activityTodaysSessions;
  String get activitySingleBlock;
  String get activityMultipleBlocks;
  String get activityThisWeekTotal;
  String get activityAcrossLast7Days;
  String get activityDailyAverage;
  String get activity7DayDailyAvg;
  String get activityChartTitle;
  String get activityChartLiveToday;
  String get activityChartDividedByDay;
  String get activityToday;
  String get activityYesterday;
  String get activityFeedHeader;
  String get activityDividedByDaySubtitle;
  String get activityEmptyState;
  String get activityAboutDialogTitle;
  String get activityAboutDialogContent;
  String get activityGotIt;
  String get activityActiveNow;
  String activityUnlockedVia(String object);
  String get activityCleanFinish;
  String get activitySingleStrike;
  String activityMultipleStrikes(int count);
  String activityNoSessionsForDay(String day);

  // Schedules Screen
  String get schedulesTitle;
  String schedulesActiveRoutines(int count);
  String get schedulesNewPlan;
  String get schedulesAddSchedule;
  String get schedulesBannerInfo;
  String get schedulesEmptyTitle;
  String get schedulesEmptySubtitle;
  String get schedulesCreateFirst;
  String get schedulesDeleteTitle;
  String schedulesDeleteContent(String name);
  String get schedulesCancel;
  String get schedulesDelete;
  String schedulesDeletedSnackbar(String name);
  String get schedulesModalTitle;
  String get schedulesModalSubtitle;
  String get schedulesRoutineName;
  String get schedulesRoutineNameHint;
  String get schedulesActiveDays;
  String get schedulesTargetObject;
  String get schedulesStartTime;
  String get schedulesDuration;
  String get schedulesCreateButton;
  String get schedulesErrorNameEmpty;
  String get schedulesErrorNoDaysSelected;
  String get scheduleEveryday;
  String get scheduleWeekdays;
  String get scheduleWeekends;
  List<String> get scheduleShortDayNames;
  List<String> get scheduleDayInitials;
  String get schedulesSave;
  String schedulesMinutes(int minutes);
  String get schedulesEditModalTitle;
  String get schedulesAssignedList;
  String get schedulesCurrentActiveList;
  String get schedulesNoListsCreated;
  String get schedulesEndTime;
  String get schedulesSetEndTime;
  String get schedulesEndsWhenStopped;
  String get schedulesUntilStopped;
  String schedulesEndsAt(String time);

  // Manage Lists Sheet
  String get manageListsTitle;
  String get manageListsActiveTitle;
  String get manageListsViewOnlyTimerActive;
  String get manageListsSelectOrEdit;
  String get manageListsLockedSessionHeader;
  String get manageListsLockedSessionDesc;
  String get manageListsEmptyTitle;
  String get manageListsEmptySubtitle;
  String get manageListsCreateNewList;
  String get manageListsNewListButton;
  String get manageListsSelectButton;
  String get manageListsActiveBadge;
  String get manageListsActiveLockedBadge;
  String get manageListsPhoneWideBadge;
  String get manageListsBlocklistBadge;
  String get manageListsEditTooltip;
  String get manageListsDeleteTooltip;
  String manageListsMoreApps(int count);
  String get manageListsEditButton;
  String get manageListsDeleteTitle;
  String manageListsDeleteContent(String name);
  String manageListsDeletedSnackbar(String name);
  String get manageListsCannotDeleteActive;

  // Create / Edit List Sheet
  String get createListTitle;
  String get editListTitle;
  String get listNameHeader;
  String get listNameLabel;
  String get listNameHint;
  String get listModeHeader;
  String get listBlockingRuleSectionHeader;
  String get listStandardModeTitle;
  String get listStandardModeDesc;
  String get listPhoneWideModeTitle;
  String get listPhoneWideModeDesc;
  String get listSelectAppsHeader;
  String listAppsToBlockHeader(int count);
  String listAppsExcludedHeader(int count);
  String get listSearchAppsHint;
  String get listSelectAll;
  String get listClear;
  String get listDeselectAll;
  String listAppsSelected(int count);
  String listFilterAll(int count);
  String listFilterSelected(int count);
  String get listFilterUserApps;
  String get listPullingApps;
  String get listNoMatchingApps;
  String get listAddCustomAppHint;
  String get listAddButton;
  String get listSaveChanges;
  String get listCreateList;
  String get listErrorNameEmpty;
  String get listCannotEditTimerActive;
  String listCreatedSnackbar(String name);
  String listUpdatedSnackbar(String name);

  // Settings Screen
  String get settingsLanguageSection;
  String get settingsAppLanguage;
  String get settingsLanguageSystem;
  String get settingsLanguageEnglish;
  String get settingsLanguageSpanish;
  String get settingsLockSection;
  String get settingsBlockerPermissions;
  String get settingsPermissionsActiveSubtitle;
  String get settingsPermissionsInactiveSubtitle;
  String get settingsCheck;
  String get settingsGrant;
  String get settingsDistractionOverlay;
  String get settingsDistractionOverlaySubtitle;
  String get settingsIosShortcutTitle;
  String get settingsIosShortcutSubtitle;
  String get settingsIosShortcutCreate;
  String get settingsIosShortcutCreated;
  String get settingsIosShortcutTest;
  String get settingsIosShortcutGuideTitle;
  String get settingsIosShortcutGuideContent;
  String get settingsCameraSection;
  String get settingsRecognizableObjects;
  String settingsItemsConfiguredSubtitle(int count);
  String get settingsConfidenceThreshold;
  String get settingsConfidenceSubtitle;
  String get settingsSoundsSection;
  String get settingsAudioCues;
  String get settingsAudioCuesSubtitle;
  String get settingsHaptic;
  String get settingsHapticSubtitle;
  String get settingsAboutSection;
  String get settingsAboutTitle;
  String get settingsAboutSubtitle;
  String get settingsCatalogTitle;
  String get settingsCatalogDesc;

  // Camera Verification Screen
  String get cameraPermissionRequired;
  String get cameraNotFound;
  String cameraInitFailed(String error);
  String cameraAnalyzingError(String error);
  String get cameraUnlockInstructions;
  String get cameraTakePicOf;
  String get cameraAnalyzing;
  String cameraVerified(String object);
  String cameraConfidence(int percent);
  String get cameraFocusLockReleased;
  String cameraNoObjectDetected(String object);
  String cameraAIRecognized(String labels);
  String get cameraOpenSettings;
  String get cameraSimulateScan;
  String get cameraBackTooltip;
  String get cameraSimulateValidScanTooltip;

  // Target Objects Translation
  String translateObject(String objectName);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    if (locale?.languageCode == 'es') {
      return EsAppStrings();
    }
    return EnAppStrings();
  }

  static AppStrings forLocale(Locale? locale) {
    if (locale?.languageCode == 'es') {
      return EsAppStrings();
    }
    return EnAppStrings();
  }
}

class EnAppStrings implements AppStrings {
  // Navigation
  @override
  String get navTimer => 'Timer';
  @override
  String get navSchedules => 'Schedules';
  @override
  String get navActivity => 'Activity';
  @override
  String get navSettings => 'Settings';

  // Timer Screen
  @override
  String get timerTodaysFocusTime => "TODAY'S FOCUS TIME";
  @override
  String get timerStartChronometer => 'Start Chronometer';
  @override
  String get timerStopAndScan => 'Stop (Scan Object to Unlock)';
  @override
  String timerPhotographObject(String object) => 'Photograph "$object"';
  @override
  String get timerTrackingTime => 'TRACKING TIME';
  @override
  String get timerVerificationPending => 'VERIFICATION PENDING';
  @override
  String get timerRequestPermissionsTooltip => 'Request Lock Permissions';
  @override
  String get timerPermissionsActive => 'Lock / overlay permissions active!';
  @override
  String get timerPermissionsDenied =>
      'Permission not granted or not supported on this device.';

  // Active List Card
  @override
  String get listNoListsCreated => 'No Lists Created';
  @override
  String get listNoAppsBlocked => 'No apps currently blocked';
  @override
  String get listTapToCreateFirst => 'Tap to create your first app list';
  @override
  String get listPhoneWideBanBadge => 'Phone-Wide Ban';
  @override
  String get listCreateButton => 'Create';
  @override
  String get listViewButton => 'View';
  @override
  String get listNewButton => 'New';
  @override
  String get listManageButton => 'Manage';
  @override
  String get listPhoneWideAllBlocked => 'Phone-wide ban (all apps blocked)';
  @override
  String get listPhoneWideSingleAllowed => 'Phone-wide ban • 1 app allowed';
  @override
  String listPhoneWideMultipleAllowed(int count) =>
      'Phone-wide ban • $count apps allowed';
  @override
  String get listStandardNoneBlocked => 'No apps blocked';
  @override
  String get listStandardSingleBlocked => '1 app blocked';
  @override
  String listStandardMultipleBlocked(int count) => '$count apps blocked';

  // Activity Screen
  @override
  String get activityHeaderBadge => 'Daily Activity Log • Real-time Tracking';
  @override
  String get activityTimerActivelyTracking => 'TIMER ACTIVELY TRACKING';
  @override
  String activityCurrentSession(String time) => 'Current session: $time';
  @override
  String get activityLoggingIntoToday =>
      "Actively logging into Today's activity tally";
  @override
  String get activityTodaysFocus => "Today's Focus";
  @override
  String get activityTrackingActively => 'Tracking actively now';
  @override
  String get activityLoggedToday => 'Logged today';
  @override
  String get activityTodaysSessions => "Today's Sessions";
  @override
  String get activitySingleBlock => '1 block recorded';
  @override
  String get activityMultipleBlocks => 'Blocks recorded';
  @override
  String get activityThisWeekTotal => 'This Week Total';
  @override
  String get activityAcrossLast7Days => 'Across last 7 days';
  @override
  String get activityDailyAverage => 'Daily Average';
  @override
  String get activity7DayDailyAvg => '7-day daily average';
  @override
  String get activityChartTitle => '7-Day Focus Distribution';
  @override
  String get activityChartLiveToday => 'Live Today';
  @override
  String get activityChartDividedByDay => 'Divided by day';
  @override
  String get activityToday => 'Today';
  @override
  String get activityYesterday => 'Yesterday';
  @override
  String get activityFeedHeader => 'Daily Activity Breakdown';
  @override
  String get activityDividedByDaySubtitle => 'Divided by Day';
  @override
  String get activityEmptyState =>
      'No activity recorded yet.\nStart the chronometer on the Timer tab to track focus time!';
  @override
  String get activityAboutDialogTitle => 'About Focus Activity';
  @override
  String get activityAboutDialogContent =>
      'This screen actively logs the duration whenever the Focus Chronometer is running.\n\nAll focus time is automatically divided by each calendar day, so you can inspect your exact study patterns and verify unlock history day by day.';
  @override
  String get activityGotIt => 'Got It';
  @override
  String get activityActiveNow => 'ACTIVE NOW';
  @override
  String activityUnlockedVia(String object) => 'Unlocked via: $object';
  @override
  String get activityCleanFinish => 'Clean finish';
  @override
  String get activitySingleStrike => '1 strike';
  @override
  String activityMultipleStrikes(int count) => '$count strikes';
  @override
  String activityNoSessionsForDay(String day) =>
      'No sessions recorded yet for $day.';

  // Schedules Screen
  @override
  String get schedulesTitle => 'Automated Routines';
  @override
  String schedulesActiveRoutines(int count) => 'Active Routines ($count)';
  @override
  String get schedulesNewPlan => 'New Plan';
  @override
  String get schedulesAddSchedule => 'Add Schedule';
  @override
  String get schedulesBannerInfo =>
      'Scheduled sessions trigger automated focus locks & reminders so you never miss study time.';
  @override
  String get schedulesEmptyTitle => 'No Active Schedules';
  @override
  String get schedulesEmptySubtitle =>
      'Create routines to automatically lock distractions during your planned focus hours.';
  @override
  String get schedulesCreateFirst => 'Create First Schedule';
  @override
  String get schedulesDeleteTitle => 'Delete Schedule?';
  @override
  String schedulesDeleteContent(String name) =>
      'Are you sure you want to delete "$name"?';
  @override
  String get schedulesCancel => 'Cancel';
  @override
  String get schedulesDelete => 'Delete';
  @override
  String schedulesDeletedSnackbar(String name) => 'Schedule "$name" deleted.';
  @override
  String get schedulesModalTitle => 'New Focus Routine';
  @override
  String get schedulesModalSubtitle => 'Set automated recurring locks';
  @override
  String get schedulesRoutineName => 'Routine Name';
  @override
  String get schedulesRoutineNameHint => 'e.g., Morning Deep Work';
  @override
  String get schedulesActiveDays => 'Active Days';
  @override
  String get schedulesTargetObject => 'Target Unlock Object';
  @override
  String get schedulesStartTime => 'Start Time';
  @override
  String get schedulesDuration => 'Duration';
  @override
  String get schedulesCreateButton => 'Create Routine';
  @override
  String get schedulesErrorNameEmpty => 'Please enter a routine name';
  @override
  String get schedulesErrorNoDaysSelected =>
      'Please select at least one active day';
  @override
  String get scheduleEveryday => 'Everyday';
  @override
  String get scheduleWeekdays => 'Weekdays (Mon-Fri)';
  @override
  String get scheduleWeekends => 'Weekends';
  @override
  List<String> get scheduleShortDayNames =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  @override
  List<String> get scheduleDayInitials =>
      const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  @override
  String get schedulesSave => 'Save Schedule';
  @override
  String schedulesMinutes(int minutes) => '$minutes min';
  @override
  String get schedulesEditModalTitle => 'Edit Focus Routine';
  @override
  String get schedulesAssignedList => 'Block List';
  @override
  String get schedulesCurrentActiveList => 'Default (Active List)';
  @override
  String get schedulesNoListsCreated => 'No custom lists yet (Default list)';
  @override
  String get schedulesEndTime => 'End Time';
  @override
  String get schedulesSetEndTime => 'Set End Time';
  @override
  String get schedulesEndsWhenStopped => 'End when stopped';
  @override
  String get schedulesUntilStopped => 'Until stopped';
  @override
  String schedulesEndsAt(String time) => 'Ends at $time';

  // Manage Lists Sheet
  @override
  String get manageListsTitle => 'Manage Lists';
  @override
  String get manageListsActiveTitle => 'Active Block List';
  @override
  String get manageListsViewOnlyTimerActive => 'View only • Timer is active';
  @override
  String get manageListsSelectOrEdit => 'Select or edit block groups';
  @override
  String get manageListsLockedSessionHeader => 'LOCKED DURING SESSION';
  @override
  String get manageListsLockedSessionDesc =>
      'Lists cannot be changed or edited while the timer is running. Stop session to modify.';
  @override
  String get manageListsEmptyTitle => 'No Block Lists Created';
  @override
  String get manageListsEmptySubtitle =>
      'Create your first list to choose which apps to block during focus sessions.';
  @override
  String get manageListsCreateNewList => 'Create New List';
  @override
  String get manageListsNewListButton => 'New List';
  @override
  String get manageListsSelectButton => 'Select';
  @override
  String get manageListsActiveBadge => 'ACTIVE';
  @override
  String get manageListsActiveLockedBadge => 'ACTIVE & LOCKED';
  @override
  String get manageListsPhoneWideBadge => 'Phone-Wide Ban';
  @override
  String get manageListsBlocklistBadge => 'Blocklist';
  @override
  String get manageListsEditTooltip => 'Edit List';
  @override
  String get manageListsDeleteTooltip => 'Delete List';
  @override
  String manageListsMoreApps(int count) => '+$count more';
  @override
  String get manageListsEditButton => 'Edit';
  @override
  String get manageListsDeleteTitle => 'Delete List?';
  @override
  String manageListsDeleteContent(String name) =>
      'Are you sure you want to delete "$name"?';
  @override
  String manageListsDeletedSnackbar(String name) => 'List "$name" deleted.';
  @override
  String get manageListsCannotDeleteActive =>
      'Cannot delete the active list during a session.';

  // Create / Edit List Sheet
  @override
  String get createListTitle => 'Create New List';
  @override
  String get editListTitle => 'Edit List';
  @override
  String get listNameHeader => 'LIST NAME';
  @override
  String get listNameLabel => 'List Name';
  @override
  String get listNameHint => 'Enter list name (e.g. Study, Work)...';
  @override
  String get listModeHeader => 'BLOCKING RULE';
  @override
  String get listBlockingRuleSectionHeader => 'BLOCKING RULE';
  @override
  String get listStandardModeTitle => 'Block Selected';
  @override
  String get listStandardModeDesc => 'Only listed apps are blocked';
  @override
  String get listPhoneWideModeTitle => 'Phone-Wide Ban';
  @override
  String get listPhoneWideModeDesc => 'All apps blocked except these';
  @override
  String get listSelectAppsHeader => 'SELECT APPS';
  @override
  String listAppsToBlockHeader(int count) => 'APPS TO BLOCK ($count selected)';
  @override
  String listAppsExcludedHeader(int count) =>
      'EXCLUDED / ALLOWED APPS ($count selected)';
  @override
  String get listSearchAppsHint => 'Search installed apps...';
  @override
  String get listSelectAll => 'Select All';
  @override
  String get listClear => 'Clear';
  @override
  String get listDeselectAll => 'Deselect All';
  @override
  String listAppsSelected(int count) => '$count apps selected';
  @override
  String listFilterAll(int count) => 'All ($count)';
  @override
  String listFilterSelected(int count) => 'Selected ($count)';
  @override
  String get listFilterUserApps => 'User Apps';
  @override
  String get listPullingApps => 'Pulling installed apps from phone...';
  @override
  String get listNoMatchingApps => 'No matching apps found';
  @override
  String get listAddCustomAppHint => 'Add custom app name...';
  @override
  String get listAddButton => 'Add';
  @override
  String get listSaveChanges => 'Save Changes';
  @override
  String get listCreateList => 'Create List';
  @override
  String get listErrorNameEmpty => 'Please enter a name for the list';
  @override
  String get listCannotEditTimerActive =>
      'Cannot create or edit lists while the timer is active!';
  @override
  String listCreatedSnackbar(String name) => 'List "$name" created!';
  @override
  String listUpdatedSnackbar(String name) => 'List "$name" updated!';

  // Settings Screen
  @override
  String get settingsLanguageSection => 'LANGUAGE / IDIOMA';
  @override
  String get settingsAppLanguage => 'App Language';
  @override
  String get settingsLanguageSystem => 'System Default';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsLockSection => 'LOCK & ANTI-CHEATING';
  @override
  String get settingsBlockerPermissions => 'Blocker Permissions';
  @override
  String get settingsPermissionsActiveSubtitle =>
      'System overlay & usage access permissions active';
  @override
  String get settingsPermissionsInactiveSubtitle =>
      'Overlay & usage access required for app blocking';
  @override
  String get settingsCheck => 'Check';
  @override
  String get settingsGrant => 'Grant';
  @override
  String get settingsDistractionOverlay => 'Distraction Overlay Blocker';
  @override
  String get settingsDistractionOverlaySubtitle =>
      'Display blocking overlay over restricted apps instead of screen pinning';
  @override
  String get settingsIosShortcutTitle => 'iOS Exit Shortcut';
  @override
  String get settingsIosShortcutSubtitle =>
      'Creates a shortcut that detects trigger and immediately exits the app';
  @override
  String get settingsIosShortcutCreate => 'Create Shortcut';
  @override
  String get settingsIosShortcutCreated =>
      'iOS exit shortcut created successfully';
  @override
  String get settingsIosShortcutTest => 'Test Exit';
  @override
  String get settingsIosShortcutGuideTitle => 'iOS Distraction Blocker Setup';
  @override
  String get settingsIosShortcutGuideContent =>
      'On iOS, you can use Apple\'s Shortcuts app to block distracting apps:\n\n1. Open the Shortcuts app on your iPhone and tap "Automation".\n2. Tap "+" > "App" and select distracting apps (e.g. social media or games).\n3. Set trigger to "Is Opened" and choose "Run Immediately".\n4. Add an action: "Open URL" with bubble://exit or run the "Exit Bubble" quick action.\n\nWhenever a restricted app is launched, Bubble will detect the trigger and immediately exit to return to the home screen.';
  @override
  String get settingsCameraSection => 'CAMERA & VISION VERIFICATION';
  @override
  String get settingsRecognizableObjects => 'Recognizable Objects';
  @override
  String settingsItemsConfiguredSubtitle(int count) =>
      '$count everyday items configured for photo unlock';
  @override
  String get settingsConfidenceThreshold => 'AI Confidence Threshold';
  @override
  String get settingsConfidenceSubtitle =>
      'Higher values require clearer, closer photos of the target object';
  @override
  String get settingsSoundsSection => 'SOUNDS & FEEDBACK';
  @override
  String get settingsAudioCues => 'Audio Cues';
  @override
  String get settingsAudioCuesSubtitle =>
      'Play chime on session start and unlock';
  @override
  String get settingsHaptic => 'Haptic Vibration';
  @override
  String get settingsHapticSubtitle =>
      'Vibrate on camera object detection confirmation';
  @override
  String get settingsAboutSection => 'ABOUT';
  @override
  String get settingsAboutTitle => 'Focus Guard App';
  @override
  String get settingsAboutSubtitle => 'Version 1.0.0 • On-Device ML Kit Vision';
  @override
  String get settingsCatalogTitle => 'Verifiable Target Objects';
  @override
  String get settingsCatalogDesc =>
      'When you want to stop a session, Focus Guard randomly assigns one of these real-world items for you to photograph:';

  // Camera Verification Screen
  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to verify objects and unlock your phone.';
  @override
  String get cameraNotFound => 'No camera found on this device.';
  @override
  String cameraInitFailed(String error) => 'Failed to initialize camera: $error';
  @override
  String cameraAnalyzingError(String error) => 'Error analyzing picture: $error';
  @override
  String get cameraUnlockInstructions =>
      'To unlock your phone and stop the timer:';
  @override
  String get cameraTakePicOf => 'Take a picture of: ';
  @override
  String get cameraAnalyzing => 'Analyzing with ML Kit...';
  @override
  String cameraVerified(String object) => 'Verified: $object!';
  @override
  String cameraConfidence(int percent) => 'Confidence: $percent%';
  @override
  String get cameraFocusLockReleased => 'Focus Lock Released 🎉';
  @override
  String cameraNoObjectDetected(String object) => 'No "$object" detected.';
  @override
  String cameraAIRecognized(String labels) => 'AI recognized: $labels';
  @override
  String get cameraOpenSettings => 'Open App Settings';
  @override
  String get cameraSimulateScan => 'Simulate Scan (Testing)';
  @override
  String get cameraBackTooltip => 'Back to Timer';
  @override
  String get cameraSimulateValidScanTooltip => 'Simulate Valid Scan (Testing)';

  @override
  String translateObject(String objectName) => objectName;
}

class EsAppStrings implements AppStrings {
  // Navigation
  @override
  String get navTimer => 'Temporizador';
  @override
  String get navSchedules => 'Horarios';
  @override
  String get navActivity => 'Actividad';
  @override
  String get navSettings => 'Ajustes';

  // Timer Screen
  @override
  String get timerTodaysFocusTime => 'TIEMPO DE ENFOQUE DE HOY';
  @override
  String get timerStartChronometer => 'Iniciar Cronómetro';
  @override
  String get timerStopAndScan => 'Detener (Escanear Objeto para Desbloquear)';
  @override
  String timerPhotographObject(String object) =>
      'Fotografía "${translateObject(object)}"';
  @override
  String get timerTrackingTime => 'TIEMPO EN CURSO';
  @override
  String get timerVerificationPending => 'VERIFICACIÓN PENDIENTE';
  @override
  String get timerRequestPermissionsTooltip =>
      'Solicitar Permisos de Bloqueo';
  @override
  String get timerPermissionsActive =>
      '¡Permisos de bloqueo / superposición activos!';
  @override
  String get timerPermissionsDenied =>
      'Permiso no concedido o no compatible con este dispositivo.';

  // Active List Card
  @override
  String get listNoListsCreated => 'Sin Listas Creadas';
  @override
  String get listNoAppsBlocked => 'Ninguna app bloqueada actualmente';
  @override
  String get listTapToCreateFirst => 'Toca para crear tu primera lista de apps';
  @override
  String get listPhoneWideBanBadge => 'Bloqueo Total';
  @override
  String get listCreateButton => 'Crear';
  @override
  String get listViewButton => 'Ver';
  @override
  String get listNewButton => 'Nueva';
  @override
  String get listManageButton => 'Gestionar';
  @override
  String get listPhoneWideAllBlocked =>
      'Bloqueo total (todas las apps bloqueadas)';
  @override
  String get listPhoneWideSingleAllowed =>
      'Bloqueo total • 1 app permitida';
  @override
  String listPhoneWideMultipleAllowed(int count) =>
      'Bloqueo total • $count apps permitidas';
  @override
  String get listStandardNoneBlocked => 'Ninguna app bloqueada';
  @override
  String get listStandardSingleBlocked => '1 app bloqueada';
  @override
  String listStandardMultipleBlocked(int count) => '$count apps bloqueadas';

  // Activity Screen
  @override
  String get activityHeaderBadge =>
      'Registro de Actividad Diaria • Monitoreo en Tiempo Real';
  @override
  String get activityTimerActivelyTracking =>
      'TEMPORIZADOR RASTREANDO ACTIVAMENTE';
  @override
  String activityCurrentSession(String time) => 'Sesión actual: $time';
  @override
  String get activityLoggingIntoToday =>
      'Registrando activamente en el cómputo de hoy';
  @override
  String get activityTodaysFocus => 'Enfoque de Hoy';
  @override
  String get activityTrackingActively => 'Rastreando activamente ahora';
  @override
  String get activityLoggedToday => 'Registrado hoy';
  @override
  String get activityTodaysSessions => 'Sesiones de Hoy';
  @override
  String get activitySingleBlock => '1 bloque registrado';
  @override
  String get activityMultipleBlocks => 'Bloques registrados';
  @override
  String get activityThisWeekTotal => 'Total de Esta Semana';
  @override
  String get activityAcrossLast7Days => 'En los últimos 7 días';
  @override
  String get activityDailyAverage => 'Promedio Diario';
  @override
  String get activity7DayDailyAvg => 'Promedio diario de 7 días';
  @override
  String get activityChartTitle => 'Distribución de Enfoque de 7 Días';
  @override
  String get activityChartLiveToday => 'En vivo hoy';
  @override
  String get activityChartDividedByDay => 'Dividido por día';
  @override
  String get activityToday => 'Hoy';
  @override
  String get activityYesterday => 'Ayer';
  @override
  String get activityFeedHeader => 'Desglose de Actividad Diaria';
  @override
  String get activityDividedByDaySubtitle => 'Dividido por Día';
  @override
  String get activityEmptyState =>
      'Aún no hay actividad registrada.\n¡Inicia el cronómetro en la pestaña Temporizador para monitorear tu tiempo de enfoque!';
  @override
  String get activityAboutDialogTitle => 'Acerca de la Actividad de Enfoque';
  @override
  String get activityAboutDialogContent =>
      'Esta pantalla registra activamente la duración cuando el Cronómetro de Enfoque está activo.\n\nTodo el tiempo de enfoque se divide automáticamente por día del calendario, para que puedas inspeccionar tus hábitos de estudio y verificar el historial de desbloqueos día a día.';
  @override
  String get activityGotIt => 'Entendido';
  @override
  String get activityActiveNow => 'ACTIVO AHORA';
  @override
  String activityUnlockedVia(String object) =>
      'Desbloqueado con: ${translateObject(object)}';
  @override
  String get activityCleanFinish => 'Finalización limpia';
  @override
  String get activitySingleStrike => '1 falta';
  @override
  String activityMultipleStrikes(int count) => '$count faltas';
  @override
  String activityNoSessionsForDay(String day) =>
      'Aún no hay sesiones registradas para $day.';

  // Schedules Screen
  @override
  String get schedulesTitle => 'Rutinas Automatizadas';
  @override
  String schedulesActiveRoutines(int count) => 'Rutinas Activas ($count)';
  @override
  String get schedulesNewPlan => 'Nuevo Plan';
  @override
  String get schedulesAddSchedule => 'Agregar Horario';
  @override
  String get schedulesBannerInfo =>
      'Las sesiones programadas activan bloqueos y recordatorios automáticos de enfoque para que nunca pierdas tu tiempo de estudio.';
  @override
  String get schedulesEmptyTitle => 'Sin Horarios Activos';
  @override
  String get schedulesEmptySubtitle =>
      'Crea rutinas para bloquear automáticamente las distracciones durante tus horas planeadas de enfoque.';
  @override
  String get schedulesCreateFirst => 'Crear Primer Horario';
  @override
  String get schedulesDeleteTitle => '¿Eliminar Horario?';
  @override
  String schedulesDeleteContent(String name) =>
      '¿Estás seguro de que deseas eliminar "$name"?';
  @override
  String get schedulesCancel => 'Cancelar';
  @override
  String get schedulesDelete => 'Eliminar';
  @override
  String schedulesDeletedSnackbar(String name) =>
      'Horario "$name" eliminado.';
  @override
  String get schedulesModalTitle => 'Nueva Rutina de Enfoque';
  @override
  String get schedulesModalSubtitle =>
      'Configura bloqueos automáticos recurrentes';
  @override
  String get schedulesRoutineName => 'Nombre de la Rutina';
  @override
  String get schedulesRoutineNameHint => 'ej., Trabajo Profundo Matutino';
  @override
  String get schedulesActiveDays => 'Días Activos';
  @override
  String get schedulesTargetObject => 'Objeto Objetivo de Desbloqueo';
  @override
  String get schedulesStartTime => 'Hora de Inicio';
  @override
  String get schedulesDuration => 'Duración';
  @override
  String get schedulesCreateButton => 'Crear Rutina';
  @override
  String get schedulesErrorNameEmpty =>
      'Por favor ingresa un nombre para la rutina';
  @override
  String get schedulesErrorNoDaysSelected =>
      'Por favor selecciona al menos un día activo';
  @override
  String get scheduleEveryday => 'Todos los días';
  @override
  String get scheduleWeekdays => 'Días laborales (Lun-Vie)';
  @override
  String get scheduleWeekends => 'Fines de semana';
  @override
  List<String> get scheduleShortDayNames =>
      const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  @override
  List<String> get scheduleDayInitials =>
      const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  @override
  String get schedulesSave => 'Guardar Horario';
  @override
  String schedulesMinutes(int minutes) => '$minutes min';
  @override
  String get schedulesEditModalTitle => 'Editar Rutina de Enfoque';
  @override
  String get schedulesAssignedList => 'Lista de Bloqueo';
  @override
  String get schedulesCurrentActiveList => 'Predeterminada (Lista Activa)';
  @override
  String get schedulesNoListsCreated => 'Sin listas personalizadas aún';
  @override
  String get schedulesEndTime => 'Hora de Fin';
  @override
  String get schedulesSetEndTime => 'Fijar Hora de Fin';
  @override
  String get schedulesEndsWhenStopped => 'Finalizar al detener';
  @override
  String get schedulesUntilStopped => 'Hasta detener';
  @override
  String schedulesEndsAt(String time) => 'Termina a las $time';

  // Manage Lists Sheet
  @override
  String get manageListsTitle => 'Gestionar Listas';
  @override
  String get manageListsActiveTitle => 'Lista de Bloqueo Activa';
  @override
  String get manageListsViewOnlyTimerActive =>
      'Solo lectura • El temporizador está activo';
  @override
  String get manageListsSelectOrEdit =>
      'Selecciona o edita grupos de bloqueo';
  @override
  String get manageListsLockedSessionHeader => 'BLOQUEADO DURANTE LA SESIÓN';
  @override
  String get manageListsLockedSessionDesc =>
      'Las listas no se pueden cambiar ni editar mientras el temporizador está en marcha. Detén la sesión para modificarlas.';
  @override
  String get manageListsEmptyTitle => 'No Hay Listas Creadas';
  @override
  String get manageListsEmptySubtitle =>
      'Crea tu primera lista para elegir qué aplicaciones bloquear durante las sesiones de enfoque.';
  @override
  String get manageListsCreateNewList => 'Crear Nueva Lista';
  @override
  String get manageListsNewListButton => 'Nueva Lista';
  @override
  String get manageListsSelectButton => 'Seleccionar';
  @override
  String get manageListsActiveBadge => 'ACTIVA';
  @override
  String get manageListsActiveLockedBadge => 'ACTIVA Y BLOQUEADA';
  @override
  String get manageListsPhoneWideBadge => 'Bloqueo Total';
  @override
  String get manageListsBlocklistBadge => 'Lista de Bloqueo';
  @override
  String get manageListsEditTooltip => 'Editar Lista';
  @override
  String get manageListsDeleteTooltip => 'Eliminar Lista';
  @override
  String manageListsMoreApps(int count) => '+$count más';
  @override
  String get manageListsEditButton => 'Editar';
  @override
  String get manageListsDeleteTitle => '¿Eliminar Lista?';
  @override
  String manageListsDeleteContent(String name) =>
      '¿Estás seguro de que deseas eliminar "$name"?';
  @override
  String manageListsDeletedSnackbar(String name) => 'Lista "$name" eliminada.';
  @override
  String get manageListsCannotDeleteActive =>
      'No se puede eliminar la lista activa durante una sesión.';

  // Create / Edit List Sheet
  @override
  String get createListTitle => 'Crear Nueva Lista';
  @override
  String get editListTitle => 'Editar Lista';
  @override
  String get listNameHeader => 'NOMBRE DE LA LISTA';
  @override
  String get listNameLabel => 'Nombre de la Lista';
  @override
  String get listNameHint => 'Ingresa el nombre de la lista (ej. Estudio, Trabajo)...';
  @override
  String get listModeHeader => 'REGLA DE BLOQUEO';
  @override
  String get listBlockingRuleSectionHeader => 'REGLA DE BLOQUEO';
  @override
  String get listStandardModeTitle => 'Bloquear Seleccionadas';
  @override
  String get listStandardModeDesc => 'Solo las apps listadas serán bloqueadas';
  @override
  String get listPhoneWideModeTitle => 'Bloqueo Total del Teléfono';
  @override
  String get listPhoneWideModeDesc => 'Todas bloqueadas excepto estas';
  @override
  String get listSelectAppsHeader => 'SELECCIONAR APLICACIONES';
  @override
  String listAppsToBlockHeader(int count) =>
      'APPS A BLOQUEAR ($count seleccionadas)';
  @override
  String listAppsExcludedHeader(int count) =>
      'APPS EXCLUIDAS / PERMITIDAS ($count seleccionadas)';
  @override
  String get listSearchAppsHint => 'Buscar aplicaciones instaladas...';
  @override
  String get listSelectAll => 'Seleccionar Todo';
  @override
  String get listClear => 'Limpiar';
  @override
  String get listDeselectAll => 'Deseleccionar Todas';
  @override
  String listAppsSelected(int count) => '$count aplicaciones seleccionadas';
  @override
  String listFilterAll(int count) => 'Todas ($count)';
  @override
  String listFilterSelected(int count) => 'Seleccionadas ($count)';
  @override
  String get listFilterUserApps => 'Apps de Usuario';
  @override
  String get listPullingApps => 'Cargando aplicaciones instaladas...';
  @override
  String get listNoMatchingApps => 'No se encontraron aplicaciones coincidentes';
  @override
  String get listAddCustomAppHint => 'Agregar nombre de app personalizado...';
  @override
  String get listAddButton => 'Agregar';
  @override
  String get listSaveChanges => 'Guardar Cambios';
  @override
  String get listCreateList => 'Crear Lista';
  @override
  String get listErrorNameEmpty =>
      'Por favor ingresa un nombre para la lista';
  @override
  String get listCannotEditTimerActive =>
      '¡No se pueden crear ni editar listas mientras el temporizador está activo!';
  @override
  String listCreatedSnackbar(String name) => '¡Lista "$name" creada!';
  @override
  String listUpdatedSnackbar(String name) => '¡Lista "$name" actualizada!';

  // Settings Screen
  @override
  String get settingsLanguageSection => 'IDIOMA / LANGUAGE';
  @override
  String get settingsAppLanguage => 'Idioma de la Aplicación';
  @override
  String get settingsLanguageSystem => 'Predeterminado del Sistema';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsLockSection => 'BLOQUEO Y ANTI-TRAMPAS';
  @override
  String get settingsBlockerPermissions => 'Permisos de Bloqueo';
  @override
  String get settingsPermissionsActiveSubtitle =>
      'Permisos de superposición del sistema y acceso de uso activos';
  @override
  String get settingsPermissionsInactiveSubtitle =>
      'Superposición y acceso de uso requeridos para bloquear apps';
  @override
  String get settingsCheck => 'Comprobar';
  @override
  String get settingsGrant => 'Conceder';
  @override
  String get settingsDistractionOverlay => 'Bloqueador por Superposición';
  @override
  String get settingsDistractionOverlaySubtitle =>
      'Mostrar superposición de bloqueo sobre apps restringidas en vez de fijar pantalla';
  @override
  String get settingsIosShortcutTitle => 'Atajo de Salida de iOS';
  @override
  String get settingsIosShortcutSubtitle =>
      'Crea un atajo que detecta la activación y sale inmediatamente de la app';
  @override
  String get settingsIosShortcutCreate => 'Crear Atajo';
  @override
  String get settingsIosShortcutCreated =>
      'Atajo de salida de iOS creado con éxito';
  @override
  String get settingsIosShortcutTest => 'Probar Salida';
  @override
  String get settingsIosShortcutGuideTitle =>
      'Configuración de Bloqueador en iOS';
  @override
  String get settingsIosShortcutGuideContent =>
      'En iOS, puedes usar la app Atajos de Apple para bloquear aplicaciones que te distraigan:\n\n1. Abre la app Atajos en tu iPhone y toca "Automatización".\n2. Toca "+" > "App" y selecciona las aplicaciones distractoras.\n3. Configura la activación como "Se abre" y "Ejecutar inmediatamente".\n4. Añade la acción: "Abrir URL" con bubble://exit o ejecuta el atajo "Exit Bubble".\n\nCada vez que se abra una app restringida, Bubble detectará la activación y saldrá de inmediato para volver a la pantalla de inicio.';
  @override
  String get settingsCameraSection => 'CÁMARA Y VERIFICACIÓN VISUAL';
  @override
  String get settingsRecognizableObjects => 'Objetos Reconocibles';
  @override
  String settingsItemsConfiguredSubtitle(int count) =>
      '$count objetos cotidianos configurados para desbloqueo por foto';
  @override
  String get settingsConfidenceThreshold => 'Umbral de Confianza de IA';
  @override
  String get settingsConfidenceSubtitle =>
      'Valores más altos requieren fotos más claras y cercanas del objeto objetivo';
  @override
  String get settingsSoundsSection => 'SONIDOS Y COMENTARIOS';
  @override
  String get settingsAudioCues => 'Señales de Audio';
  @override
  String get settingsAudioCuesSubtitle =>
      'Reproducir sonido al iniciar sesión y al desbloquear';
  @override
  String get settingsHaptic => 'Vibración Háptica';
  @override
  String get settingsHapticSubtitle =>
      'Vibrar al confirmar la detección del objeto con la cámara';
  @override
  String get settingsAboutSection => 'ACERCA DE';
  @override
  String get settingsAboutTitle => 'Aplicación Focus Guard';
  @override
  String get settingsAboutSubtitle =>
      'Versión 1.0.0 • Visión ML Kit en el Dispositivo';
  @override
  String get settingsCatalogTitle => 'Objetos Objetivo Verificables';
  @override
  String get settingsCatalogDesc =>
      'Cuando deseas detener una sesión, Focus Guard asigna aleatoriamente uno de estos objetos reales para que lo fotografíes:';

  // Camera Verification Screen
  @override
  String get cameraPermissionRequired =>
      'Se requiere permiso de cámara para verificar objetos y desbloquear el teléfono.';
  @override
  String get cameraNotFound => 'No se encontró ninguna cámara en este dispositivo.';
  @override
  String cameraInitFailed(String error) =>
      'Error al inicializar la cámara: $error';
  @override
  String cameraAnalyzingError(String error) =>
      'Error al analizar la imagen: $error';
  @override
  String get cameraUnlockInstructions =>
      'Para desbloquear tu teléfono y detener el temporizador:';
  @override
  String get cameraTakePicOf => 'Toma una foto de: ';
  @override
  String get cameraAnalyzing => 'Analizando con ML Kit...';
  @override
  String cameraVerified(String object) =>
      '¡Verificado: ${translateObject(object)}!';
  @override
  String cameraConfidence(int percent) => 'Confianza: $percent%';
  @override
  String get cameraFocusLockReleased => '¡Bloqueo de Enfoque Liberado! 🎉';
  @override
  String cameraNoObjectDetected(String object) =>
      'No se detectó "${translateObject(object)}".';
  @override
  String cameraAIRecognized(String labels) => 'La IA reconoció: $labels';
  @override
  String get cameraOpenSettings => 'Abrir Ajustes de la App';
  @override
  String get cameraSimulateScan => 'Simular Escaneo (Prueba)';
  @override
  String get cameraBackTooltip => 'Regresar al Temporizador';
  @override
  String get cameraSimulateValidScanTooltip =>
      'Simular Escaneo Válido (Prueba)';

  @override
  String translateObject(String objectName) {
    switch (objectName.toLowerCase()) {
      case 'cup':
        return 'Taza';
      case 'coffee cup':
        return 'Taza de café';
      case 'mug':
        return 'Tazón / Pocillo';
      case 'shoe':
        return 'Zapato';
      case 'footwear':
        return 'Calzado';
      case 'computer keyboard':
        return 'Teclado de computadora';
      case 'laptop':
        return 'Portátil / Laptop';
      case 'bottle':
        return 'Botella';
      case 'chair':
        return 'Silla';
      case 'watch':
      case 'clock':
      case 'wrist watch':
        return 'Reloj';
      default:
        return objectName;
    }
  }
}
