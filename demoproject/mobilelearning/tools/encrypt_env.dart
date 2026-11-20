// tool/encrypt_env.dart  (DO NOT SHIP)
// dart run tool/encrypt_env.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

Future<void> main(List<String> args) async {
  final inputPath = args.isNotEmpty ? args[0] : '.env';
  final outputPath = args.length > 1 ? args[1] : 'assets/env/.env.enc';

  // TODO: Provide your 32-byte key & 12-byte nonce here ONLY for tooling.
  // In production app, DO NOT keep these literals; fetch differently.
  final keyBytes = Uint8List.fromList(List<int>.from([
    // 32 bytes sample — REPLACE with your own
    21, 134, 9, 77, 190, 13, 44, 199, 18, 251, 60, 9, 99, 140, 200, 11,
    91, 42, 210, 79, 201, 33, 87, 166, 18, 44, 199, 89, 10, 210, 33, 77
  ]));
  final nonce = Uint8List.fromList(
      [11, 22, 33, 44, 55, 66, 77, 88, 99, 10, 20, 30]); // 12 bytes

  final envText = await File(inputPath).readAsString();
  final algo = AesGcm.with256bits();
  final secretKey = SecretKey(keyBytes);

  final secretBox = await algo.encrypt(
    utf8.encode(envText),
    secretKey: secretKey,
    nonce: nonce,
  );

  // Store as base64(ciphertext || tag). Nonce is supplied at runtime in app.
  final out = Uint8List.fromList(
    [...secretBox.cipherText, ...secretBox.mac.bytes],
  );
  final b64 = base64Encode(out);

  final outFile = File(outputPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(b64);
  stdout.writeln('Wrote encrypted env to: $outputPath');
}
