import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam_seg_app/core/localization/app_strings.dart';
import 'package:exam_seg_app/core/localization/locale_controller.dart';
import 'package:exam_seg_app/features/lists/models/app_block_list.dart';
import 'package:exam_seg_app/features/schedules/models/schedule_item.dart';

void main() {
  group('AppStrings and Localization Tests', () {
    test('forLocale returns EsAppStrings for Spanish and EnAppStrings for English/null', () {
      expect(AppStrings.forLocale(const Locale('es')), isA<EsAppStrings>());
      expect(AppStrings.forLocale(const Locale('en')), isA<EnAppStrings>());
      expect(AppStrings.forLocale(null), isA<EnAppStrings>());
    });

    test('Object translations map properly in Spanish', () {
      final es = EsAppStrings();
      final en = EnAppStrings();

      expect(es.translateObject('Laptop'), 'Portátil / Laptop');
      expect(es.translateObject('Coffee cup'), 'Taza de café');
      expect(es.translateObject('Shoe'), 'Zapato');
      expect(es.translateObject('Clock'), 'Reloj');
      expect(es.translateObject('Chair'), 'Silla');
      expect(es.translateObject('Computer keyboard'), 'Teclado de computadora');

      // English retains original labels
      expect(en.translateObject('Laptop'), 'Laptop');
      expect(en.translateObject('Coffee cup'), 'Coffee cup');
    });

    test('AppBlockList localized summaries format properly', () {
      final es = EsAppStrings();
      final en = EnAppStrings();

      final standardList = AppBlockList(
        id: '1',
        name: 'Study',
        appNames: ['Instagram', 'TikTok'],
        createdAt: DateTime.now(),
        isPhoneWideBan: false,
      );

      expect(standardList.localizedBlockedSummary(en), '2 apps blocked');
      expect(standardList.localizedBlockedSummary(es), '2 apps bloqueadas');
      expect(standardList.localizedModeTitle(en), 'Blocklist');
      expect(standardList.localizedModeTitle(es), 'Lista de Bloqueo');

      final phoneWideList = AppBlockList(
        id: '2',
        name: 'Strict Mode',
        appNames: ['Clock'],
        createdAt: DateTime.now(),
        isPhoneWideBan: true,
      );

      expect(phoneWideList.localizedBlockedSummary(en), 'Phone-wide ban • 1 app allowed');
      expect(phoneWideList.localizedBlockedSummary(es), 'Bloqueo total • 1 app permitida');
      expect(phoneWideList.localizedModeTitle(en), 'Phone-Wide Ban');
      expect(phoneWideList.localizedModeTitle(es), 'Bloqueo Total');
    });

    test('ScheduleItem localized days summary formats properly', () {
      final es = EsAppStrings();
      final en = EnAppStrings();

      final everydaySchedule = ScheduleItem(
        id: '1',
        title: 'Morning',
        time: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 30,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
      );

      expect(everydaySchedule.localizedDaysSummary(en), 'Everyday');
      expect(everydaySchedule.localizedDaysSummary(es), 'Todos los días');

      final weekdaysSchedule = ScheduleItem(
        id: '2',
        title: 'Work',
        time: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 45,
        repeatDays: [1, 2, 3, 4, 5],
      );

      expect(weekdaysSchedule.localizedDaysSummary(en), 'Weekdays (Mon-Fri)');
      expect(weekdaysSchedule.localizedDaysSummary(es), 'Días laborales (Lun-Vie)');
    });

    test('LocaleController changes locale correctly', () {
      final controller = LocaleController();
      expect(controller.state, isNull); // default system

      controller.setLocale(const Locale('es'));
      expect(controller.state, const Locale('es'));

      controller.setLocale(const Locale('en'));
      expect(controller.state, const Locale('en'));

      controller.setLocale(null);
      expect(controller.state, isNull);
    });
  });
}
