import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/model/proposal_status.dart';
import 'package:mobile_onboarding/screens/newDashboard/components/status_list_view.dart';
import 'package:mobile_onboarding/screens/noorcard/noor_card_screen.dart';
import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
import 'package:mobile_onboarding/utilities/api_services/products_loctionChecker.dart';
import 'package:mobile_onboarding/utilities/criteriaCheckService/ApiService.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/widgets/default_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utilities/internet_checker/connectivity_checker.dart';
import '../../loan/components/dynamic_form.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ScrollController _controller = ScrollController();
  List<LoanRequestInformation> loanRequests = [];
  List<ProposalStatus> proposalStatus = [];
  int requestId = 0;
  int stepsCompleted = 0;
  bool openRequest = false;
  bool _isLoading = false; // Add this line
  int count = 0;
  Future<void> getLoanRequestsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.database;
      loanRequests = await databaseHelper.getAllLoanRequestInformation();
      if (loanRequests.isNotEmpty) {
        count = loanRequests.length;
      }
      setState(() {});
    } catch (e) {
      return null;
    }
  }

  void getProposals() async {
    try {
      // await getProposalStatus();
      await getLoanRequestsFromDB();
      for (LoanRequestInformation item in loanRequests) {
        proposalStatus.add(
            ProposalStatus('${item.requestId}', item.status, '', 'Noor Card'));
        if (item.status == 'incomplete') {
          requestId = item.requestId;
          stepsCompleted = item.stepsCompleted;
          openRequest = true;
          print("resume completed step ${stepsCompleted}");
        }
      }
    } catch (e) {
      showError(e);
      print('Exception in getProposals(): $e');
    }
  }

  @override
  void initState() {
    super.initState();

    getProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectivityBanner(),
        Flexible(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: MediaQuery.of(context).size.width,

            decoration: const BoxDecoration(
              color: Color(0xFFf3f3f3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: const StatusListView(),
            //child: FoldingCellListView(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 22),
          child: DefaultButton(
              // text: (count > 0) ? 'Resume Journey' : 'Apply Noor Card',
              text: 'Resume Journey',
              isDisable: (count > 0 && journeyType == "NTB") ? true : false,
              press: () {
                if (count > 0 && journeyType == "NTB") {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => DynamicForm(
                                requestId,
                                stepsCompleted + 1,
                                true,
                                productType,
                              )))
                      .then((_) => setState(() {
                            loanRequests.clear();
                            proposalStatus.clear();
                            requestId = 0;
                            stepsCompleted = 0;
                            openRequest = false;
                            getProposals();
                          }));
                  // } else {
                  // Navigator.pushNamed(context, NoorCardScreen.routeName);
                  // }
                } else {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => DynamicForm(0, 0, false, productType),
                  // ));
                  // Navigator.pushNamed(context, NoorCardScreen.routeName);
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: TextButton(
            onPressed: () async {
              // bool isCriteriaMet =
              //     await checkEligibilityAndLocationAndMaybeWarn(
              //   context,
              //   longitude: longitude,
              //   latitude: latitude,
              // );

              // Navigator.pop(context);
              // if (!isCriteriaMet) {
              //   return;
              // }
              Navigator.pushNamed(context, NoorCardScreen.routeName);
              print(globalProductValue);
            },
            child: Text(
              'New Application', // Replace with the name of your button
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                decoration: TextDecoration.underline, // Underlines the text
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 10),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: TextStyle(color: kPrimaryColor, fontSize: 15.sp),
              children: const [
                TextSpan(
                    text:
                        'For further assistance or queries, please contact our helpline '),
                TextSpan(
                  text: '021-111-060606.',
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
