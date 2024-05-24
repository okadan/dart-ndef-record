# ndef_record

A Dart implementation of the NFC Data Exchange Format (NDEF) specification.

## Example

Currently this package only provides the low-level API of the NDEF specification, so you will need to implement encoding/decoding of byte data yourself.

### NdefRecord

```dart
// Well-Known Record (RTD:T)
NdefRecord(
  typeNameFormat: TypeNameFormat.wellKnown,
  type: ascii.encode('T'),
  identifier: Uint8List(0),
  payload: Uint8List.fromList([
    0x02,
    ...ascii.encode('en'),
    ...ascii.encode('Hello'),
  ]),
);

// Well-Known Record (RTD:U)
NdefRecord(
  typeNameFormat: TypeNameFormat.wellKnown,
  type: ascii.encode('U'),
  identifier: Uint8List(0),
  payload: Uint8List.fromList([
    0x03,
    ...utf8.encode('example.com'),
  ]),
);

// Mime Record
NdefRecord(
  typeNameFormat: TypeNameFormat.media,
  type: ascii.encode('text/plain'),
  identifier: Uint8List(0),
  payload: ascii.encode('Hello'),
);

// External Record (Android Application)
NdefRecord(
  typeNameFormat: TypeNameFormat.external,
  type: ascii.encode('android.com:pkg'),
  identifier: Uint8List(0),
  payload: utf8.encode('example'),
);

// and more...
```
