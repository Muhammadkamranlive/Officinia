import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import '../../../constants.dart';

class CustomCard extends StatefulWidget {
  final String imagePath; // This should be the base64-encoded string
  final String heading;
  final String? subheading;
  final String? productID;
  final bool isEnabled;
  final int? Jcount;
  final VoidCallback? onTap;

  CustomCard({
    super.key,
    required this.imagePath,
    required this.heading,
    this.subheading,
    this.isEnabled = true,
    this.productID,
    this.Jcount,
    this.onTap,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  List<LoanRequestInformation> loanRequests = [];
  int _count = 0;

  Future<void> getLoanRequestsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      loanRequests = await databaseHelper.getAllLoanRequestInformation();
      if (loanRequests.isNotEmpty) {
        setState(() {
          _count = loanRequests.length;
        });
      }
    } catch (e) {
      // Handle exception
      showError(e);
      print('Error fetching loan requests: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getLoanRequestsFromDB();
  }

  bool isCardEnabled() {
    // if (widget.productID == "IJ" && widget.Jcount == 0) {
    //   return false;
    // }
    // if (widget.productID == 'CC' && widget.Jcount! > 0) {
    //   return false;
    // }
    if (widget.productID == "AnS") {
      return true;
    }
    if (widget.productID == "D" ||
        widget.productID == "LS" ||
        widget.productID == "CS") {
      return false;
    }
    return true;
  }

  // Decode base64 image string
  Uint8List? convertBase64Image(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool cardEnabled = isCardEnabled();

    // Decode the base64 string to Uint8List
    Uint8List? imageBytes = convertBase64Image(widget.imagePath);

    return GestureDetector(
      onTap: cardEnabled ? widget.onTap : null,
      child: IgnorePointer(
        ignoring: !cardEnabled,
        child: Card(
          color: cardEnabled ? Colors.white : Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the image if it's not null
                if (imageBytes != null)
                  Align(
                    alignment: Alignment.center,
                    child: Image.memory(
                      imageBytes, // Display decoded image
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),
                  ),

                const Spacer(),
                Text(
                  widget.heading,
                  style: cardEnabled
                      ? cardHeading
                      : cardHeading.copyWith(color: Colors.grey),
                ),
                if (widget.subheading != null)
                  Text(
                    widget.subheading!,
                    style: cardEnabled
                        ? cardSubHeadingStyle
                        : cardSubHeadingStyle.copyWith(color: Colors.grey),
                  ),
                if (widget.productID == 100 && widget.Jcount! > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    '(${widget.Jcount})',
                    style: cardEnabled
                        ? cardHeading
                        : cardHeading.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
