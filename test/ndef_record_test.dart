import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';
import 'package:test/test.dart';

void main() {
  group('NdefMessage#equality', () {
    final target = NdefMessage(
      records: [
        NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x01]),
          identifier: Uint8List.fromList([0x02]),
          payload: Uint8List.fromList([0x03]),
        ),
        NdefRecord(
          typeNameFormat: TypeNameFormat.media,
          type: Uint8List.fromList([0x01]),
          identifier: Uint8List.fromList([0x02]),
          payload: Uint8List.fromList([0x03]),
        ),
      ],
    );

    test('equal', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x01]),
            identifier: Uint8List.fromList([0x02]),
            payload: Uint8List.fromList([0x03]),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.media,
            type: Uint8List.fromList([0x01]),
            identifier: Uint8List.fromList([0x02]),
            payload: Uint8List.fromList([0x03]),
          ),
        ],
      );
      expect(message, equals(target));
      expect(message.hashCode, equals(target.hashCode));
      expect(message, isNot(same(target)));
    });

    for (final c in <({String name, NdefMessage message})>[(
      name: 'different record',
      message: NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x09]),
            identifier: Uint8List.fromList([0x09]),
            payload: Uint8List.fromList([0x09]),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.media,
            type: Uint8List.fromList([0x09]),
            identifier: Uint8List.fromList([0x09]),
            payload: Uint8List.fromList([0x09]),
          ),
        ],
      ),
    ), (
      name: 'different second record',
      message: NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x01]),
            identifier: Uint8List.fromList([0x02]),
            payload: Uint8List.fromList([0x03]),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.external,
            type: Uint8List.fromList([0x09]),
            identifier: Uint8List.fromList([0x09]),
            payload: Uint8List.fromList([0x09]),
          ),
        ],
      ),
    ), (
      name: 'different number of records',
      message: NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x01]),
            identifier: Uint8List.fromList([0x02]),
            payload: Uint8List.fromList([0x03]),
          ),
        ],
      ),
    )]) {
      test(c.name, () {
        expect(c.message, isNot(equals(target)));
        expect(c.message, isNot(same(target)));
      });
    }
  });

  group('NdefMessage#byteLength', () {
    for (final c in <({String name, int expected, NdefMessage message})>[(
      name: 'empty records',
      expected: 0,
      message: NdefMessage(records: []),
    ), (
      name: 'total byteLength of records',
      expected: 275,
      message: NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.empty,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List(0),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x01]),
            identifier: Uint8List.fromList([0x01]),
            payload: Uint8List.fromList([0x01]),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x01]),
            identifier: Uint8List.fromList([0x01]),
            payload: Uint8List.fromList(List.filled(256, 0x01)),
          ),
        ],
      ),
    )]) {
      test(c.name, () {
        expect(c.message.byteLength, equals(c.expected));
      });
    }
  });

  group('NdefRecord#equality', () {
    final target = NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x01]),
      identifier: Uint8List.fromList([0x02]),
      payload: Uint8List.fromList([0x03]),
    );

    test('equal', () {
      final record = NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x01]),
        identifier: Uint8List.fromList([0x02]),
        payload: Uint8List.fromList([0x03]),
      );
      expect(record, equals(target));
      expect(record.hashCode, equals(target.hashCode));
      expect(record, isNot(same(target)));
    });

    for (final p in <({String name, NdefRecord record})>[(
      name: 'different typeNameFormat',
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.media,
        type: Uint8List.fromList([0x01]),
        identifier: Uint8List.fromList([0x02]),
        payload: Uint8List.fromList([0x03]),
      ),
    ), (
      name: 'different type',
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x09]),
        identifier: Uint8List.fromList([0x02]),
        payload: Uint8List.fromList([0x03]),
      ),
    ), (
      name: 'different identifier',
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x01]),
        identifier: Uint8List.fromList([0x09]),
        payload: Uint8List.fromList([0x03]),
      ),
    ), (
      name: 'different payload',
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x01]),
        identifier: Uint8List.fromList([0x02]),
        payload: Uint8List.fromList([0x09]),
      ),
    ),
    ]) {
      test(p.name, () {
        expect(p.record, isNot(equals(target)));
        expect(p.record, isNot(same(target)));
      });
    }
  });

  group('NdefRecord#byteLength', () {
    for (final c in <({String name, int expected, NdefRecord record})>[(
      name: 'empty record',
      expected: 3,
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.empty,
        type: Uint8List(0),
        identifier: Uint8List(0),
        payload: Uint8List(0),
      ),
    ), (
      name: 'short record',
      expected: 7,
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x01]),
        identifier: Uint8List.fromList([0x01]),
        payload: Uint8List.fromList([0x01]),
      ),
    ), (
      name: 'long record',
      expected: 265,
      record: NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x01]),
        identifier: Uint8List.fromList([0x01]),
        payload: Uint8List.fromList(List.filled(256, 0x01)),
      ),
    )]) {
      test(c.name, () {
        expect(c.record.byteLength, equals(c.expected));
      });
    }
  });
}
