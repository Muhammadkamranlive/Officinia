import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/productdetails/product_detail_screen.dart';
import 'package:mobile_onboarding/widgets/screen_arguments.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;
  final Function press;
  List<dynamic> itemDetailList = [];

  CustomCard({
    Key? key,
    required this.title,
    required this.itemDetailList,
    required this.description,
    this.imagePath,
    required name,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(34.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.13,
              ),
              Text(
                title,
                // style: const TextStyle(
                //   color: kPrimaryColor,
                //   fontWeight: FontWeight.w900,
                //   fontFamily: 'Avenir',
                //   fontSize: 40,
                // ),
                style: headingStyle,
                textAlign: TextAlign.left,
              ),
              Text(
                maxLines: 3,
                description,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Avenir',
                  fontSize: 18,
                ),
                textAlign: TextAlign.left,
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        press();
                        List<dynamic> itemDetails = itemDetailList[0];
                        print(itemDetails);
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            ProductsDetailScreen.routeName,
                            arguments:
                                ScreenArguments("", "", false, itemDetails),
                            (Route<dynamic> route) => true);
                      } catch (e) {
                        // print('Exception in fetching location: $e');
                        // if (pr.isShowing()) {
                        //   await pr.hide();
                        // }
                      }
                    },
                    child: const Text(
                      "Apply Now",
                      style: TextStyle(
                        color: kPrimaryLightColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Avenir',
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(
                      Ionicons.arrow_forward,
                      color: kPrimaryLightColor,
                      size: 20,
                    ),
                  )
                ],
              ),
              // const SizedBox(
              //   height: 24,
              // ),
              // Image.asset(
              //   imagePath,
              //   fit: BoxFit.cover,
              //   height: 200,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
