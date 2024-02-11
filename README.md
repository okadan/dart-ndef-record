# ndef_record

A Dart implementation of the NFC Data Exchange Format (NDEF) specification.

## Example

```dart
NdefMessage(
  records: [
    // Well-Known Text Record: (en) Hello World
    NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([
        0x54,
      ]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([
        0x02,
        0x65, 0x6e,
        0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64,
      ]),
    ),

    // Well-Known URI Record: http://example.com
    NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([
        0x55,
      ]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([
        0x03,
        0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63, 0x6f, 0x6d,
      ]),
    ),

    // Mime Record: (text/plain) Hello
    NdefRecord(
      typeNameFormat: TypeNameFormat.media,
      type: Uint8List.fromList([
        0x74, 0x65, 0x78, 0x74, 0x2f, 0x70, 0x6c, 0x61, 0x69, 0x6e,
      ]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([
        0x48, 0x65, 0x6c, 0x6c, 0x6f,
      ]),
    ),

    // etc... See the NDEF Specification for more informations.
  ],
);
```
