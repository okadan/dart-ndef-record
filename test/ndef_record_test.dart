import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';
import 'package:test/test.dart';

void main() {
  group('NdefMessage#equality', () {
    final target = NdefMessage(
      records: [
        NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList([0x00]),
        ),
        NdefRecord(
          typeNameFormat: TypeNameFormat.media,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList([0x00]),
        ),
      ],
    );

    test('equal', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x00]),
            identifier: Uint8List.fromList([0x00]),
            payload: Uint8List.fromList([0x00]),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.media,
            type: Uint8List.fromList([0x00]),
            identifier: Uint8List.fromList([0x00]),
            payload: Uint8List.fromList([0x00]),
          ),
        ],
      );
      expect(message, equals(target));
      expect(message.hashCode, equals(target.hashCode));
      expect(message, isNot(same(target)));
    });

    for (final c in <({String name, NdefMessage message})>[
      (
        name: 'different record',
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x01]),
              identifier: Uint8List.fromList([0x01]),
              payload: Uint8List.fromList([0x01]),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.media,
              type: Uint8List.fromList([0x01]),
              identifier: Uint8List.fromList([0x01]),
              payload: Uint8List.fromList([0x01]),
            ),
          ],
        ),
      ),
      (
        name: 'different second record',
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x00]),
              identifier: Uint8List.fromList([0x00]),
              payload: Uint8List.fromList([0x00]),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.external,
              type: Uint8List.fromList([0x01]),
              identifier: Uint8List.fromList([0x01]),
              payload: Uint8List.fromList([0x01]),
            ),
          ],
        ),
      ),
      (
        name: 'different number of records',
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x00]),
              identifier: Uint8List.fromList([0x00]),
              payload: Uint8List.fromList([0x00]),
            ),
          ],
        ),
      ),
    ]) {
      test(c.name, () {
        expect(c.message, isNot(equals(target)));
        expect(c.message, isNot(same(target)));
      });
    }
  });

  group('NdefMessage#byteLength', () {
    for (final c in <({String name, int expected, NdefMessage message})>[
      (name: 'empty records', expected: 0, message: NdefMessage(records: [])),
      (
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
              type: Uint8List.fromList([0x00]),
              identifier: Uint8List.fromList([0x00]),
              payload: Uint8List.fromList([0x00]),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x00]),
              identifier: Uint8List.fromList([0x00]),
              payload: Uint8List.fromList(List.filled(256, 0x00)),
            ),
          ],
        ),
      ),
    ]) {
      test(c.name, () {
        expect(c.message.byteLength, equals(c.expected));
      });
    }
  });

  group('NdefRecord#equality', () {
    final target = NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x00]),
      identifier: Uint8List.fromList([0x00]),
      payload: Uint8List.fromList([0x00]),
    );

    test('equal', () {
      final record = NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x00]),
        identifier: Uint8List.fromList([0x00]),
        payload: Uint8List.fromList([0x00]),
      );
      expect(record, equals(target));
      expect(record.hashCode, equals(target.hashCode));
      expect(record, isNot(same(target)));
    });

    for (final p in <({String name, NdefRecord record})>[
      (
        name: 'different typeNameFormat',
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.media,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList([0x00]),
        ),
      ),
      (
        name: 'different type',
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x01]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList([0x00]),
        ),
      ),
      (
        name: 'different identifier',
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x01]),
          payload: Uint8List.fromList([0x00]),
        ),
      ),
      (
        name: 'different payload',
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList([0x01]),
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
    for (final c in <({String name, int expected, NdefRecord record})>[
      (
        name: 'empty record',
        expected: 3,
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.empty,
          type: Uint8List(0),
          identifier: Uint8List(0),
          payload: Uint8List(0),
        ),
      ),
      (
        name: 'short record',
        expected: 7,
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList([0x00]),
        ),
      ),
      (
        name: 'long record',
        expected: 265,
        record: NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x00]),
          identifier: Uint8List.fromList([0x00]),
          payload: Uint8List.fromList(List.filled(256, 0x00)),
        ),
      ),
    ]) {
      test(c.name, () {
        expect(c.record.byteLength, equals(c.expected));
      });
    }
  });

  group('NdefMessage#encode', () {
    test('throws when records is empty', () {
      expect(() => NdefMessage(records: []).encode(), throwsFormatException);
    });

    test('throws when maxChunkPayloadLength is less than 1', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.empty,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List(0),
          ),
        ],
      );
      expect(() => message.encode(maxChunkPayloadLength: 0), throwsArgumentError);
    });

    test('throws when a record type exceeds 255 bytes', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List(256),
            identifier: Uint8List(0),
            payload: Uint8List(0),
          ),
        ],
      );
      expect(message.encode, throwsFormatException);
    });

    test('throws when a record identifier exceeds 255 bytes', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List(0),
            identifier: Uint8List(256),
            payload: Uint8List(0),
          ),
        ],
      );
      expect(message.encode, throwsFormatException);
    });

    for (final c in <({String name, List<int> expected, NdefMessage message})>[
      (
        name: 'single empty record',
        expected: [0xD0, 0x00, 0x00],
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.empty,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List(0),
            ),
          ],
        ),
      ),
      (
        name: 'single short record with id',
        expected: [0xD9, 0x01, 0x01, 0x01, 0x54, 0x02, 0x03],
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]),
              identifier: Uint8List.fromList([0x02]),
              payload: Uint8List.fromList([0x03]),
            ),
          ],
        ),
      ),
      (
        name: 'MB set only on first record, ME set only on last record',
        expected: [0x90, 0x00, 0x00, 0x50, 0x00, 0x00],
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.empty,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List(0),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.empty,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List(0),
            ),
          ],
        ),
      ),
    ]) {
      test(c.name, () {
        expect(c.message.encode(), equals(Uint8List.fromList(c.expected)));
      });
    }
  });

  group('NdefMessage#decode', () {
    test('throws on empty bytes', () {
      expect(() => NdefMessage.decode(Uint8List(0)), throwsFormatException);
    });

    test('throws when MB is missing on the first record', () {
      // ME=1, SR=1, TNF=empty(0), no MB.
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0x50, 0x00, 0x00])),
        throwsFormatException,
      );
    });

    test('throws on trailing data after the ME record', () {
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0xD0, 0x00, 0x00, 0x00])),
        throwsFormatException,
      );
    });

    test('throws on truncated bytes', () {
      // Declares a 1-byte payload but the stream ends before it.
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0xD1, 0x01, 0x01])),
        throwsFormatException,
      );
    });

    test('throws when missing the ME record', () {
      // MB=1, SR=1, TNF=empty(0), no ME.
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0x90, 0x00, 0x00])),
        throwsFormatException,
      );
    });

    test('throws on reserved TNF value 0x07', () {
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0xD7, 0x00, 0x00])),
        throwsFormatException,
      );
    });

    for (final c in <({String name, NdefMessage expected, List<int> bytes})>[
      (
        name: 'single empty record',
        bytes: [0xD0, 0x00, 0x00],
        expected: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.empty,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List(0),
            ),
          ],
        ),
      ),
      (
        name: 'single short record with id',
        bytes: [0xD9, 0x01, 0x01, 0x01, 0x54, 0x02, 0x03],
        expected: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]),
              identifier: Uint8List.fromList([0x02]),
              payload: Uint8List.fromList([0x03]),
            ),
          ],
        ),
      ),
    ]) {
      test(c.name, () {
        expect(NdefMessage.decode(Uint8List.fromList(c.bytes)), equals(c.expected));
      });
    }
  });

  group('NdefMessage#encode/decode round trip', () {
    for (final c in <({String name, NdefMessage message})>[
      (
        name: 'empty record',
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.empty,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List(0),
            ),
          ],
        ),
      ),
      (
        name: 'multiple records including a long record',
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]),
              identifier: Uint8List.fromList([0x02]),
              payload: Uint8List.fromList([0x03]),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.media,
              type: Uint8List.fromList('text/plain'.codeUnits),
              identifier: Uint8List.fromList([0x01, 0x02]),
              payload: Uint8List.fromList(List.filled(300, 0x41)),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.external,
              type: Uint8List.fromList('example.com:x'.codeUnits),
              identifier: Uint8List(0),
              payload: Uint8List.fromList([0x99]),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.unknown,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List(0),
            ),
          ],
        ),
      ),
      (
        // Only a chunked record's first chunk requires a type field, so an
        // unchunked record without one stays readable.
        name: 'record without a type field',
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List(0),
              identifier: Uint8List(0),
              payload: Uint8List.fromList([0xAA]),
            ),
          ],
        ),
      ),
    ]) {
      test(c.name, () {
        final encoded = c.message.encode();
        expect(encoded.length, equals(c.message.byteLength));
        expect(NdefMessage.decode(encoded), equals(c.message));
      });
    }
  });

  group('NdefMessage#encode payload length field', () {
    NdefMessage messageWithPayloadLength(int length) {
      return NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x54]),
            identifier: Uint8List(0),
            payload: Uint8List.fromList(List.filled(length, 0xAA)),
          ),
        ],
      );
    }

    test('uses a 1-byte length with SR set at 255 bytes', () {
      final message = messageWithPayloadLength(255);
      final encoded = message.encode();
      expect(encoded.sublist(0, 4), equals(Uint8List.fromList([0xD1, 0x01, 0xFF, 0x54])));
      expect(encoded.length, equals(259));
      expect(message.byteLength, equals(259));
    });

    test('uses a 4-byte big-endian length with SR clear at 256 bytes', () {
      final message = messageWithPayloadLength(256);
      final encoded = message.encode();
      expect(
        encoded.sublist(0, 7),
        equals(Uint8List.fromList([0xC1, 0x01, 0x00, 0x00, 0x01, 0x00, 0x54])),
      );
      expect(encoded.length, equals(263));
      expect(message.byteLength, equals(263));
    });

    test('decodes a 4-byte big-endian length', () {
      final bytes = Uint8List.fromList([
        0xC1, 0x01, 0x00, 0x00, 0x01, 0x00, 0x54, //
        ...List.filled(256, 0xAA),
      ]);
      expect(NdefMessage.decode(bytes), equals(messageWithPayloadLength(256)));
    });
  });

  group('NdefMessage#decode truncation', () {
    test('throws for every truncated prefix', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.media,
            type: Uint8List.fromList('text/plain'.codeUnits),
            identifier: Uint8List.fromList([0x01, 0x02]),
            payload: Uint8List.fromList(List.filled(300, 0x41)),
          ),
          NdefRecord(
            typeNameFormat: TypeNameFormat.empty,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List(0),
          ),
        ],
      );
      final encoded = message.encode();

      for (var i = 0; i < encoded.length; i++) {
        expect(
          () => NdefMessage.decode(encoded.sublist(0, i)),
          throwsFormatException,
          reason: 'a prefix of length $i must not decode',
        );
      }
      expect(NdefMessage.decode(encoded), equals(message));
    });
  });

  group('NdefMessage#encode chunked', () {
    test('does not chunk when every payload fits within maxChunkPayloadLength', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0x01, 0x02]),
          ),
        ],
      );
      expect(message.encode(maxChunkPayloadLength: 100), equals(message.encode()));
    });

    test('throws when chunking a record without a type field', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0xAA, 0xBB]),
          ),
        ],
      );
      expect(() => message.encode(maxChunkPayloadLength: 1), throwsFormatException);
    });

    test('chunks a record without a type field when its TNF is UNKNOWN', () {
      final message = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0xAA, 0xBB]),
          ),
        ],
      );
      final encoded = message.encode(maxChunkPayloadLength: 1);
      expect(encoded, equals(Uint8List.fromList([0xB5, 0x00, 0x01, 0xAA, 0x56, 0x00, 0x01, 0xBB])));
      expect(NdefMessage.decode(encoded), equals(message));
    });

    for (final c in <({String name, int maxChunkPayloadLength, NdefMessage message})>[
      (
        name: 'single record split into three chunks',
        maxChunkPayloadLength: 10,
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]),
              identifier: Uint8List.fromList([0x02]),
              payload: Uint8List.fromList(List.generate(25, (i) => i)),
            ),
          ],
        ),
      ),
      (
        name: 'payload length is an exact multiple of the chunk size',
        maxChunkPayloadLength: 10,
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.external,
              type: Uint8List.fromList('example.com:x'.codeUnits),
              identifier: Uint8List(0),
              payload: Uint8List.fromList(List.filled(20, 0x07)),
            ),
          ],
        ),
      ),
      (
        name: 'chunked record followed by a normal record',
        maxChunkPayloadLength: 7,
        message: NdefMessage(
          records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]),
              identifier: Uint8List.fromList([0x02]),
              payload: Uint8List.fromList(List.generate(25, (i) => i)),
            ),
            NdefRecord(
              typeNameFormat: TypeNameFormat.media,
              type: Uint8List.fromList('text/plain'.codeUnits),
              identifier: Uint8List(0),
              payload: Uint8List.fromList([0x42]),
            ),
          ],
        ),
      ),
    ]) {
      test(c.name, () {
        final encoded = c.message.encode(maxChunkPayloadLength: c.maxChunkPayloadLength);
        expect(
          encoded.length,
          greaterThan(c.message.encode().length),
          reason: 'chunking should add extra physical record headers',
        );
        expect(NdefMessage.decode(encoded), equals(c.message));
      });
    }
  });

  group('NdefMessage#decode chunked', () {
    test('reassembles a chunked record from hand-built bytes', () {
      // Chunk 1: MB=1, CF=1, SR=1, IL=1, TNF=wellKnown(1); id=[0x02];
      // payload=[0x01, 0x02, 0x03].
      // Chunk 2 (terminating): ME=1, SR=1, TNF=UNCHANGED(6); no type or id;
      // payload=[0x04, 0x05].
      final bytes = Uint8List.fromList([
        0xB9, 0x01, 0x03, 0x01, 0x54, 0x02, 0x01, 0x02, 0x03, //
        0x56, 0x00, 0x02, 0x04, 0x05,
      ]);
      final expected = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x54]),
            identifier: Uint8List.fromList([0x02]),
            payload: Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05]),
          ),
        ],
      );
      expect(NdefMessage.decode(bytes), equals(expected));
    });

    test('throws when the first chunk has no type field', () {
      // MB=1, CF=1, SR=1, TNF=wellKnown(1), but TYPE_LENGTH = 0.
      final bytes = Uint8List.fromList([
        0xB1, 0x00, 0x01, 0xAA, //
        0x56, 0x00, 0x01, 0xBB,
      ]);
      expect(() => NdefMessage.decode(bytes), throwsFormatException);
    });

    test('allows a first chunk with no type field when its TNF is UNKNOWN', () {
      // MB=1, CF=1, SR=1, TNF=unknown(5).
      final bytes = Uint8List.fromList([
        0xB5, 0x00, 0x01, 0xAA, //
        0x56, 0x00, 0x01, 0xBB,
      ]);
      final expected = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.unknown,
            type: Uint8List(0),
            identifier: Uint8List(0),
            payload: Uint8List.fromList([0xAA, 0xBB]),
          ),
        ],
      );
      expect(NdefMessage.decode(bytes), equals(expected));
    });

    test('throws when a chunk (CF = 1) also sets ME', () {
      // MB=1, ME=1, CF=1, SR=1, TNF=wellKnown(1).
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0xF1, 0x00, 0x01, 0x00])),
        throwsFormatException,
      );
    });

    test('throws when a continuation has the wrong TNF', () {
      final bytes = Uint8List.fromList([
        0xB1, 0x01, 0x01, 0x54, 0x00, // MB=1, CF=1, SR=1, TNF=wellKnown(1)
        0x51, 0x00, 0x01, 0x00, // ME=1, SR=1, TNF=wellKnown(1) (should be UNCHANGED)
      ]);
      expect(() => NdefMessage.decode(bytes), throwsFormatException);
    });

    test('throws when a continuation carries an id', () {
      final bytes = Uint8List.fromList([
        0xB1, 0x01, 0x01, 0x54, 0x00, // MB=1, CF=1, SR=1, TNF=wellKnown(1)
        0x5E, 0x00, 0x01, 0x01, 0x00, 0x00, // ME=1, SR=1, IL=1, TNF=UNCHANGED(6)
      ]);
      expect(() => NdefMessage.decode(bytes), throwsFormatException);
    });

    test('throws when a chunk sequence is left unterminated', () {
      // MB=1, CF=1, SR=1, TNF=wellKnown(1) with no following chunk.
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0xB1, 0x01, 0x01, 0x54, 0x00])),
        throwsFormatException,
      );
    });

    test('throws for a standalone UNCHANGED record', () {
      // MB=1, ME=1, SR=1, TNF=UNCHANGED(6), with CF=0 (not part of a chunk).
      expect(
        () => NdefMessage.decode(Uint8List.fromList([0xD6, 0x00, 0x00])),
        throwsFormatException,
      );
    });
  });
}
