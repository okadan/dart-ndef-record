import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';
import 'package:test/test.dart';

void main() {
  group('NdefRecord', () {
    for (final p in <({
      String name,
      TypeNameFormat typeNameFormat,
      Uint8List type,
      Uint8List identifier,
      Uint8List payload,
    })>[
      (
        name: 'EMPTY(1)',
        typeNameFormat: TypeNameFormat.empty,
        type: Uint8List(1),
        identifier: Uint8List(0),
        payload: Uint8List(0),
      ),
      (
        name: 'EMPTY(2)',
        typeNameFormat: TypeNameFormat.empty,
        type: Uint8List(0),
        identifier: Uint8List(1),
        payload: Uint8List(0),
      ),
      (
        name: 'EMPTY(3)',
        typeNameFormat: TypeNameFormat.empty,
        type: Uint8List(0),
        identifier: Uint8List(0),
        payload: Uint8List(1),
      ),
      (
        name: 'UNKNOWN',
        typeNameFormat: TypeNameFormat.unknown,
        type: Uint8List(1),
        identifier: Uint8List(0),
        payload: Uint8List(0),
      ),
      (
        name: 'UNCHANGED',
        typeNameFormat: TypeNameFormat.unchanged,
        type: Uint8List(0),
        identifier: Uint8List(0),
        payload: Uint8List(0),
      )
    ]) {
      test('throws FormatException if the fields are invalid [${p.name}]', () {
        expect(
          () => NdefRecord(
            typeNameFormat: p.typeNameFormat,
            type: p.type,
            identifier: p.identifier,
            payload: p.payload,
          ),
          throwsFormatException,
        );
      });
    }

    for (final p in <({
      String name,
      NdefRecord target,
      int expected,
    })>[
      (
        name: 'empty',
        target: NdefRecord(
          typeNameFormat: TypeNameFormat.empty,
          type: Uint8List(0),
          identifier: Uint8List(0),
          payload: Uint8List(0),
        ),
        expected: 4,
      ),
      (
        name: 'identifier length',
        target: NdefRecord(
          typeNameFormat: TypeNameFormat.unknown,
          type: Uint8List(0),
          identifier: Uint8List.fromList([0x00, 0x01]),
          payload: Uint8List.fromList([0x02, 0x03]),
        ),
        expected: 8,
      ),
      (
        name: 'long payload',
        target: NdefRecord(
          typeNameFormat: TypeNameFormat.unknown,
          type: Uint8List(0),
          identifier: Uint8List(0),
          payload: Uint8List.fromList([
            ...('a' * 256).codeUnits,
          ]),
        ),
        expected: 262,
      ),
    ]) {
      test('byteLength [${p.name}]', () {
        expect(p.target.byteLength, p.expected);
      });
    }
  });
}
