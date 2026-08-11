import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/utils/display_name.dart';

void main() {
  group('splitDisplayName', () {
    test('splits a simple two part name', () {
      final name = splitDisplayName('Diane Magno');

      expect(name.firstName, 'Diane');
      expect(name.lastName, 'Magno');
    });

    test('keeps every middle part with the last name', () {
      final name = splitDisplayName('Diane Marie Santos Magno');

      expect(name.firstName, 'Diane');
      expect(name.lastName, 'Marie Santos Magno');
    });

    test('leaves the last name empty for a single word', () {
      final name = splitDisplayName('Diane');

      expect(name.firstName, 'Diane');
      expect(name.lastName, isEmpty);
    });

    test('collapses repeated and surrounding whitespace', () {
      final name = splitDisplayName('   Diane    Magno   ');

      expect(name.firstName, 'Diane');
      expect(name.lastName, 'Magno');
    });

    test('returns empty parts for null, empty or blank input', () {
      for (final value in [null, '', '   ', '\t\n']) {
        final name = splitDisplayName(value);

        expect(name.firstName, isEmpty, reason: '$value');
        expect(name.lastName, isEmpty, reason: '$value');
      }
    });
  });
}
