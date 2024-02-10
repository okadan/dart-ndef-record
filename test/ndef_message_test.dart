import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';
import 'package:test/test.dart';

void main() {
  group('NdefMessage', () {
    for (final p in <({
      String name,
      NdefMessage target,
      NdefMessage other,
      bool expected,
    })>[
      (
        name: 'empty',
        target: NdefMessage(records: []),
        other: NdefMessage(records: []),
        expected: true,
      ),
      (
        name: 'expected true',
        target: NdefMessage(records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0x00]),
          ),
        ]),
        other: NdefMessage(records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0x00]),
          ),
        ]),
        expected: true,
      ),
      (
        name: 'expected false',
        target: NdefMessage(records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0x00]),
          ),
        ]),
        other: NdefMessage(records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0x01]),
          ),
        ]),
        expected: false,
      ),
    ]) {
      test('correctly formats [${p.name}]', () {
        expect(p.target.hashCode == p.other.hashCode, p.expected);
        expect(p.target == p.other, p.expected);
      });
    }

    test('byteLength must be sum of all records', () {
      expect(
        NdefMessage(records: [
          // empty
          NdefRecord(
            typeNameFormat: TypeNameFormat.empty,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List(0),
          ),
          // identifier length
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List.fromList([0x00, 0x01]),
            payload: Uint8List.fromList([0x02, 0x03]),
          ),
          // long payload
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([
              ...('a' * 256).codeUnits,
            ]),
          ),
        ]).byteLength,
        274,
      );
    });
  });
}
