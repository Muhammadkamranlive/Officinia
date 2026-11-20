import 'package:flutter/material.dart';
import 'package:mobile_onboarding/model/form_field_data_new.dart';
import '../constants.dart';

class NadraVerificationButton extends StatefulWidget {
  final FormFieldDataNew fieldData;
  final VoidCallback onPressed;

  const NadraVerificationButton({
    Key? key,
    required this.fieldData,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<NadraVerificationButton> createState() =>
      _NadraVerificationButtonState();
}

class _NadraVerificationButtonState extends State<NadraVerificationButton> {

  @override
  void initState() {
    super.initState();
    // Invoke the callback automatically (after the first frame is rendered)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Replace this with whatever UI you want to show
    // (or return an empty Container if you don’t want any UI).
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          widget.fieldData.fieldPlaceholder,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
