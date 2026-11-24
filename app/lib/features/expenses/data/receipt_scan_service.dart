import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/ai/sipho_ai_client.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/parsed_receipt.dart';
import 'receipt_parser.dart';

class ReceiptScanService {
  ReceiptScanService(this._ref);

  final Ref _ref;
  final _picker = ImagePicker();

  Future<XFile?> pick({required ImageSource source}) {
    return _picker.pickImage(
      source: source,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );
  }

  /// Client Firebase AI Logic first (ADR-004), then server `parseReceipt`.
  Future<ParsedReceipt> uploadAndParse(XFile file) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) {
      throw StateError('Not signed in');
    }

    final bytes = await file.readAsBytes();
    final id = _receiptId();
    final ext = file.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final storagePath = 'receipts/$uid/$id.$ext';
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final storageRef = _ref.read(firebaseStorageProvider).ref(storagePath);
    await storageRef.putFile(
      File(file.path),
      SettableMetadata(contentType: contentType),
    );

    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('receipts')
        .doc(id)
        .set({'storagePath': storagePath, 'status': 'uploaded'});

    try {
      final clientParsed =
          await _ref.read(receiptParserProvider).parse(bytes);
      if (clientParsed.isReceipt && clientParsed.totalCents != null) {
        return clientParsed.copyWith(storagePath: storagePath);
      }
    } on SiphoAiException catch (e) {
      debugPrint('[scan] client AI failed, falling back to server: $e');
    } catch (e) {
      debugPrint('[scan] client AI failed, falling back to server: $e');
    }

    final result = await _ref
        .read(cloudFunctionsServiceProvider)
        .parseReceipt(storagePath: storagePath);

    if (result['status'] == 'error') {
      throw StateError(result['message']?.toString() ?? 'parse failed');
    }

    return ParsedReceipt.fromModelJson({
      ...result,
      'storagePath': storagePath,
      'isReceipt': true,
    }).copyWith(storagePath: storagePath);
  }

  String _receiptId() {
    final r = Random.secure();
    final ms = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final suffix =
        List.generate(8, (_) => r.nextInt(36).toRadixString(36)).join();
    return '$ms$suffix';
  }
}

final receiptScanServiceProvider = Provider<ReceiptScanService>((ref) {
  return ReceiptScanService(ref);
});
