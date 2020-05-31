import 'package:flutter_test/flutter_test.dart';
import 'package:messapp/util/date.dart';

void main() {
  group('Date', () {
    group('Parsing', () {
      group('ISO formatted + valid', () {
        test('Format-1', () {
          final date = Date.parse('2020-05-31');

          expect(date.day, 31);
          expect(date.month, 5);
          expect(date.year, 2020);
        });

        test('Format-2', () {
          expect(() => Date.parse('20200531'), returnsNormally);
        });
      });

      test('ISO formatted + wrong', () {
        expect(() => Date.parse('2020-05-32'), returnsNormally);
      });

      group('Non-ISO formatted', () {
        test('0-padding problems', () {
          expect(() => Date.parse('2020-5-31'), throwsFormatException);
        });

        test('Invalid separators', () {
          expect(() => Date.parse('2020:05:31'), throwsFormatException);
          expect(() => Date.parse('2020 05 31'), throwsFormatException);
        });
      });

      test('Random shit', () {
        expect(() => Date.parse('Quick dogs'), throwsFormatException);
      });
    });

    test('To ISO-8601 string', () {
      final date = Date(2020, 5, 7);

      expect(date.toIso8601String(), '2020-05-07');
    });
    group('Comparison', () {
      test('Date1 > Date2', () {
        final date1 = Date(2020, 8, 28);
        final date2 = Date(2020, 8, 17);

        expect(date1.compareTo(date2), 1);
      });

      test('Date1 < Date2', () {
        final date1 = Date(2020, 6, 29);
        final date2 = Date(2020, 8, 17);

        expect(date1.compareTo(date2), -1);
      });

      test('Date1 == Date2', () {
        final date1 = Date(2020, 8, 17);
        final date2 = Date(2020, 8, 17);

        expect(date1.compareTo(date2), 0);
      });
    });
  });

  group('DateFormatter', () {
    test('Weekday', () {
      final date = Date(2020, 5, 31);

      expect(DateFormatter(date).weekDay, 'Sunday');
    });

    test('Month', () {
      final date = Date(2020, 5, 31);

      expect(DateFormatter(date).month, 'May');
    });
  });
}
