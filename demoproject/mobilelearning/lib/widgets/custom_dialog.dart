import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class CustomDialogBox extends StatefulWidget {
  Function onCameraBTNPressed, onGalleryBTNPressed;

  CustomDialogBox(
      {required this.onCameraBTNPressed, required this.onGalleryBTNPressed});

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Scan Your ID',
                textAlign: TextAlign.center,
                style: headingStyle,
              ),
              const Text(
                'Use high quality camera for better experience',
                textAlign: TextAlign.center,
                style: labelStyle,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset('assets/images/id_instructions_large.png'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 135,
                    height: 46,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: kPrimaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onCameraBTNPressed();
                        },
                        child: const Text(
                          'CAMERA',
                          //style: TextStyle(fontSize: buttonSize, color: kPrimaryColor),
                        )),
                  ),
                  SizedBox(
                    width: 135,
                    height: 46,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: kPrimaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onGalleryBTNPressed();
                        },
                        child: const Text(
                          'GALLERY',
                          //style: TextStyle(fontSize: buttonSize, color: kPrimaryColor),
                        )),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
