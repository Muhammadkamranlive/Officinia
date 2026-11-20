import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/newDashboard/alerts_status_screen.dart';
import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/newSingupMain.dart';

void showFailDialog(
  BuildContext context,
  // ignore: non_constant_identifier_names
  String ApiMessege,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green Check Icon
              const Center(
                child: Icon(
                  Icons.sms_failed_outlined,
                  color: Colors.red,
                  size: 80,
                ),
              ),
              const SizedBox(height: 20),

              // Congratulation Text
              Center(
                child: Text(
                  'Failure',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      fontFamily: "Circular"),
                ),
              ),
              const SizedBox(height: 20),

              // Paragraphs
              Text(
                'Dear AbuHurraira,',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: "Circular"),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              Text(
                ApiMessege,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: "Circular"),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              Text(
                'For further assistance or queries, please contact our helpline 021-111-060606.',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: "Circular"),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),

              // Rectangular Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: newSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => AlertsStatusScreen()));
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontFamily: "Circular"),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showSuccessDialog(
  String firstName,
  BuildContext context,
) {
  showDialog(
    barrierColor: Colors.white,
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {},
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green Check Icon
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: newSecondaryColor,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 20),

                // Congratulation Text
                Center(
                  child: Text(
                    'Congratulations!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                        fontFamily: "Circular"),
                  ),
                ),
                const SizedBox(height: 20),

                // Paragraphs
                Text(
                  'Dear ${firstName}',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: "Circular"),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your application for Faysal Noor Card has been submitted successfully. Our team will contact you shortly,',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: "Circular"),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Text(
                  'For further assistance or queries, please contact our helpline 021-111-060606.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: "Circular"),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),

                // Rectangular Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: newSecondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    onPressed: () {
                      // Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => AlertsStatusScreen()),
                        ModalRoute.withName(NewSignUpScreen
                            .routeName), // or LoginScreen.routeName
                      );
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: "Circular"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
