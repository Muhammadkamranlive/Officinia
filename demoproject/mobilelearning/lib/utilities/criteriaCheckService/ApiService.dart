import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

Future<bool> checkCriteria() async {
  final cnic = await UserSecretStore.getCnic();
  if (cnic == null || cnic.isEmpty) return false;

  final url = Uri.parse(
    '${getApiBaseUrl()}/LOS/checkCriteria?cnic=$cnic&productId=$globalProductValue',
  );

  try {
    final header = await getGenericHeaders();
    final client = await createHttpClientWithPinnedCert();
    final response = await client.get(url, headers: header);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final dataValue = (responseBody['data']?.toString() ?? '').trim();
      return dataValue.toUpperCase() == 'Y';
    } else {
      return false;
    }
  } catch (_) {
    return false;
  }
}

Future<bool> checkProductByLocation(
  BuildContext context,
  double? longitude,
  double? latitude,
) async {
  final url = Uri.parse(
    '${getApiBaseUrl()}/LOS/productByLocation?productCodeId=$globalProductValue&longitude=$longitude&latitude=$latitude',
  );

  try {
    final client = await createHttpClientWithPinnedCert();
    final headers = await getGenericHeaders();
    final response = await client.get(url, headers: headers);

    // Close the loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final data = (responseData['data']?.toString() ?? '').toUpperCase();
      return data == 'Y';
    } else {
      return false;
    }
  } catch (e) {
    // Close loader if still open
    Navigator.of(context, rootNavigator: true).maybePop();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: const Text(
            'An error occurred while checking product availability.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return false;
  }
}

/// Returns true only if criteria == 'Y' AND productByLocation == 'Y'.
Future<bool> checkEligibilityAndLocationAndMaybeWarn(
  BuildContext context, {
  required double? longitude,
  required double? latitude,
}) async {
  // 1) Criteria first
  final criteriaOk = await checkCriteria();
  if (!criteriaOk) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Already Applied'),
        content: const Text('You already applied for this product.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  }

  // 2) Only if criteria passes, check location availability
  _showBlockingLoader(context, message: 'Checking availability...');
  final availableHere =
      await checkProductByLocation(context, longitude, latitude);

  if (!availableHere) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Not Available'),
        content: const Text('This product is not available in your area.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  }

  return true;
}

void _showBlockingLoader(BuildContext context, {String? message}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 120),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(message, style: const TextStyle(color: Colors.white)),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
