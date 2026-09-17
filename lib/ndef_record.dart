import 'dart:typed_data' show BytesBuilder, Uint8List;

import 'package:collection/collection.dart';

const _iterableEquality = IterableEquality<Object>();

/// The values that indicate the content type for the payload data.
enum TypeNameFormat {
  /// The payload contains no data.
  empty,

  /// The payload contains well-known record type data.
  wellKnown,

  /// The payload contains media data as defined by RFC 2046.
  media,

  /// The payload contains data typed by an absolute URI.
  absoluteUri,

  /// The payload contains NFC external type data.
  external,

  /// The payload data type is unknown.
  unknown,

  /// The payload is part of a series of records containing chunked data.
  unchanged,
}

/// The NDEF message consisting of a list of records.
final class NdefMessage {
  /// Constructs an NDEF message from a list of records.
  const NdefMessage({required this.records});

  /// The list of records for the message.
  final List<NdefRecord> records;

  /// The length of this message in bytes, as encoded without chunking.
  ///
  /// This matches the length of [encode] called without
  /// `maxChunkPayloadLength`. Chunking may increase the encoded length:
  /// shorter payload length fields can offset the extra chunk headers.
  int get byteLength {
    return records.fold(0, (p, e) => p + e.byteLength);
  }

  /// Encodes this message into its NDEF binary wire format.
  ///
  /// The first physical record's MB bit and the last physical record's
  /// ME bit are set automatically. If [maxChunkPayloadLength] is given,
  /// any record whose payload is longer than it is split into a chunked
  /// sequence of physical records (CF = 1 on all but the last chunk, and
  /// TNF = UNCHANGED on all but the first); otherwise every record is
  /// encoded as a single, unchunked physical record.
  ///
  /// Throws [FormatException] if [records] is empty, if any record's
  /// `type` or `identifier` is longer than 255 bytes, or if a record
  /// that would be chunked has an empty `type` and a TNF other than
  /// UNKNOWN. Throws [ArgumentError] if [maxChunkPayloadLength] is given
  /// and is less than 1.
  Uint8List encode({int? maxChunkPayloadLength}) {
    if (records.isEmpty) {
      throw FormatException('Cannot encode a message with no records.');
    }
    if (maxChunkPayloadLength != null && maxChunkPayloadLength < 1) {
      throw ArgumentError.value(
        maxChunkPayloadLength,
        'maxChunkPayloadLength',
        'Must be at least 1 when given.',
      );
    }

    final builder = BytesBuilder();
    var isFirstPhysicalRecord = true;

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final isLastRecord = i == records.length - 1;
      final segments = record._splitPayload(maxChunkPayloadLength);

      for (var j = 0; j < segments.length; j++) {
        final isLastSegment = j == segments.length - 1;
        record._encodeSegment(
          builder,
          payload: segments[j],
          continuation: j > 0,
          chunkFlag: !isLastSegment,
          messageBegin: isFirstPhysicalRecord,
          messageEnd: isLastRecord && isLastSegment,
        );
        isFirstPhysicalRecord = false;
      }
    }

    return builder.toBytes();
  }

  /// Decodes an [NdefMessage] from its NDEF binary wire format.
  ///
  /// [bytes] must contain exactly one complete NDEF message, from the
  /// first physical record's MB bit through the last physical record's
  /// ME bit, with no leading or trailing bytes. Chunked records
  /// (CF = 1, followed by TNF = UNCHANGED continuations) are reassembled
  /// into a single logical [NdefRecord].
  ///
  /// Throws [FormatException] if [bytes] is malformed or truncated, if
  /// the MB/ME bits are inconsistent, or if a chunk sequence is
  /// malformed or left unterminated.
  factory NdefMessage.decode(Uint8List bytes) {
    var offset = 0;

    int readByte() {
      if (offset >= bytes.length) {
        throw FormatException('Truncated NDEF message.');
      }
      return bytes[offset++];
    }

    Uint8List readBytes(int length) {
      if (offset + length > bytes.length) {
        throw FormatException('Truncated NDEF message.');
      }
      final result = bytes.sublist(offset, offset + length);
      offset += length;
      return result;
    }

    final records = <NdefRecord>[];
    var isFirstPhysicalRecord = true;
    var messageEnded = false;

    // The chunk sequence currently being reassembled, if any.
    TypeNameFormat? chunkTnf;
    Uint8List? chunkType;
    Uint8List? chunkId;
    BytesBuilder? chunkPayload;

    while (offset < bytes.length) {
      if (messageEnded) {
        throw FormatException('Unexpected data after the ME record.');
      }

      final header = readByte();
      final messageBegin = header & 0x80 != 0;
      final messageEnd = header & 0x40 != 0;
      final chunkFlag = header & 0x20 != 0;
      final shortRecord = header & 0x10 != 0;
      final hasId = header & 0x08 != 0;
      final tnf = header & 0x07;

      if (isFirstPhysicalRecord != messageBegin) {
        throw FormatException('MB bit must be set on the first record only.');
      }
      isFirstPhysicalRecord = false;
      if (chunkFlag && messageEnd) {
        throw FormatException('ME bit must not be set on a chunked record.');
      }
      if (tnf == 0x07) {
        throw FormatException('Reserved TNF value 0x07 is not allowed.');
      }

      final typeLength = readByte();
      final payloadLength = shortRecord
          ? readByte()
          : (readByte() << 24) |
              (readByte() << 16) |
              (readByte() << 8) |
              readByte();
      final idLength = hasId ? readByte() : 0;

      final type = readBytes(typeLength);
      final identifier = readBytes(idLength);
      final payload = readBytes(payloadLength);

      final inChunk = chunkPayload != null;

      if (!inChunk && tnf == TypeNameFormat.unchanged.index) {
        throw FormatException(
          'Unexpected UNCHANGED record outside of a chunk sequence.',
        );
      }

      if (inChunk) {
        if (tnf != TypeNameFormat.unchanged.index || typeLength != 0 || hasId) {
          throw FormatException(
            'A chunk continuation must have TNF = UNCHANGED and no type or id.',
          );
        }
        chunkPayload.add(payload);
        if (!chunkFlag) {
          records.add(
            NdefRecord(
              typeNameFormat: chunkTnf!,
              type: chunkType!,
              identifier: chunkId!,
              payload: chunkPayload.toBytes(),
            ),
          );
          chunkTnf = null;
          chunkType = null;
          chunkId = null;
          chunkPayload = null;
        }
      } else if (chunkFlag) {
        if (typeLength == 0 && tnf != TypeNameFormat.unknown.index) {
          throw FormatException(
            'The first chunk of a chunked record must have a type field.',
          );
        }
        chunkTnf = TypeNameFormat.values[tnf];
        chunkType = type;
        chunkId = identifier;
        chunkPayload = BytesBuilder()..add(payload);
      } else {
        records.add(
          NdefRecord(
            typeNameFormat: TypeNameFormat.values[tnf],
            type: type,
            identifier: identifier,
            payload: payload,
          ),
        );
      }

      messageEnded = messageEnd;
    }

    if (chunkPayload != null) {
      throw FormatException('Unterminated chunked record.');
    }
    if (!messageEnded) {
      throw FormatException('Incomplete NDEF message: missing ME record.');
    }

    return NdefMessage(records: records);
  }

  @override
  int get hashCode {
    return Object.hashAll(records);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NdefMessage &&
        _iterableEquality.equals(other.records, records);
  }
}

/// The NDEF record in a message.
final class NdefRecord {
  const NdefRecord._({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  });

  /// The Type Name Format field of the record, as defined by the NDEF specification.
  final TypeNameFormat typeNameFormat;

  /// The type of the record, as defined by the NDEF specification.
  final Uint8List type;

  /// The identifier of the record, as defined by the NDEF specification.
  final Uint8List identifier;

  /// The payload of the record, as defined by the NDEF specification.
  final Uint8List payload;

  /// Constructs an NDEF record from its fields.
  ///
  /// Throws [FormatException] if a valid record cannot be created.
  factory NdefRecord({
    required TypeNameFormat typeNameFormat,
    required Uint8List type,
    required Uint8List identifier,
    required Uint8List payload,
  }) {
    switch (typeNameFormat) {
      case TypeNameFormat.empty:
        if (type.isNotEmpty || identifier.isNotEmpty || payload.isNotEmpty) {
          throw FormatException('Unexpected data in EMPTY record.');
        }
      case TypeNameFormat.unknown:
        if (type.isNotEmpty) {
          throw FormatException('Unexpected type field in UNKNOWN record.');
        }
      case TypeNameFormat.unchanged:
        throw FormatException(
          'Unexpected UNCHANGED record in first chunk or logical record.',
        );
      default:
        break;
    }
    return NdefRecord._(
      typeNameFormat: typeNameFormat,
      type: type,
      identifier: identifier,
      payload: payload,
    );
  }

  /// The length of this record in bytes, as encoded without chunking.
  int get byteLength {
    // header + type length + payload length
    int length = 3;

    if (typeNameFormat == TypeNameFormat.empty) {
      return length;
    }

    length += type.length + payload.length;

    // id length
    if (identifier.isNotEmpty) {
      length += 1;
      length += identifier.length;
    }

    // long record
    if (payload.length > 255) {
      length += 3;
    }

    return length;
  }

  /// Splits [payload] into the physical payload segments to encode.
  ///
  /// Returns a single-element list (the whole payload, unchunked) when
  /// [maxChunkPayloadLength] is `null` or the payload already fits
  /// within it; otherwise returns the payload split into segments of at
  /// most [maxChunkPayloadLength] bytes each.
  List<Uint8List> _splitPayload(int? maxChunkPayloadLength) {
    if (type.length > 255) {
      throw FormatException('Record type must not exceed 255 bytes.');
    }
    if (identifier.length > 255) {
      throw FormatException('Record identifier must not exceed 255 bytes.');
    }
    if (maxChunkPayloadLength == null ||
        payload.length <= maxChunkPayloadLength) {
      return [payload];
    }
    if (type.isEmpty && typeNameFormat != TypeNameFormat.unknown) {
      throw FormatException(
        'Cannot chunk a record without a type field unless its TNF is '
        'UNKNOWN.',
      );
    }

    final segments = <Uint8List>[];
    for (var o = 0; o < payload.length; o += maxChunkPayloadLength) {
      final end = o + maxChunkPayloadLength < payload.length
          ? o + maxChunkPayloadLength
          : payload.length;
      segments.add(payload.sublist(o, end));
    }
    return segments;
  }

  /// Encodes one physical NDEF record carrying [payload] into [builder].
  ///
  /// The MB/ME bits are supplied by the enclosing [NdefMessage] since
  /// they depend on this record's position in the message. [continuation]
  /// marks a chunk continuation, which is encoded with TNF = UNCHANGED
  /// and no type or id; [chunkFlag] sets CF to indicate that another
  /// chunk of this same logical record follows.
  void _encodeSegment(
    BytesBuilder builder, {
    required Uint8List payload,
    required bool continuation,
    required bool chunkFlag,
    required bool messageBegin,
    required bool messageEnd,
  }) {
    final effectiveTnf = continuation ? TypeNameFormat.unchanged : typeNameFormat;
    final effectiveType = continuation ? Uint8List(0) : type;
    final hasId = !continuation && identifier.isNotEmpty;
    final shortRecord = payload.length <= 255;

    var header = effectiveTnf.index;
    if (messageBegin) header |= 0x80;
    if (messageEnd) header |= 0x40;
    if (chunkFlag) header |= 0x20;
    if (shortRecord) header |= 0x10;
    if (hasId) header |= 0x08;

    builder.addByte(header);
    builder.addByte(effectiveType.length);

    if (shortRecord) {
      builder.addByte(payload.length);
    } else {
      final length = payload.length;
      builder.addByte((length >> 24) & 0xFF);
      builder.addByte((length >> 16) & 0xFF);
      builder.addByte((length >> 8) & 0xFF);
      builder.addByte(length & 0xFF);
    }

    if (hasId) builder.addByte(identifier.length);

    builder.add(effectiveType);
    if (hasId) builder.add(identifier);
    builder.add(payload);
  }

  @override
  int get hashCode {
    return Object.hashAll([typeNameFormat, ...type, ...identifier, ...payload]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NdefRecord &&
        other.typeNameFormat == typeNameFormat &&
        _iterableEquality.equals(other.type, type) &&
        _iterableEquality.equals(other.identifier, identifier) &&
        _iterableEquality.equals(other.payload, payload);
  }
}
