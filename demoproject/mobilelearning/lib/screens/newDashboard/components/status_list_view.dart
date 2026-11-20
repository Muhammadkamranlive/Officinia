import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/screens/requests/components/request_card.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:mobile_onboarding/widgets/new_application.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../model/proposal_status.dart';
import '../../../widgets/default_button.dart';
import '../../../widgets/etb_application.dart';

import '../../noorcard/noor_card_screen.dart';

import 'package:http/http.dart' as http;

class StatusListView extends StatefulWidget {
  const StatusListView({Key? key}) : super(key: key);

  @override
  State<StatusListView> createState() => _FoldingCellListViewState();
}

class _FoldingCellListViewState extends State<StatusListView> {
  ScrollController _controller = new ScrollController();
  List<LoanRequestInformation> loanRequests = [];
  List<ProposalStatus> proposalStatus = [];
  int requestId = 0;
  int stepsCompleted = 0;
  bool openRequest = false;
  Future<void> _refreshProposals() async {
    proposalStatus.clear();
    await getProposals();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // getProposalStatus();
    //getLoanRequestsFromDB();
    getProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // Flexible
          child: proposalStatus.length > 0
              ? RefreshIndicator(
                  displacement: 40,
                  edgeOffset: 10,
                  onRefresh: _refreshProposals,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: proposalStatus.length,
                    // loanRequests.length
                    itemBuilder: (context, index) => RequestCard(
                      id: int.tryParse(proposalStatus[index].appRef) ?? 0,

                      // loanRequests[index].requestId
                      status: proposalStatus[index].status,
                      // loanRequests[index].status.toUpperCase()
                      productName: proposalStatus[index].productName.length >=
                              20
                          ? '${proposalStatus[index].productName.substring(0, 20)} ...'
                          : proposalStatus[index].productName,
                      press: () {
                        /*
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DynamicForm(
                                loanRequests[index].requestId,
                                loanRequests[index].status == "complete"
                                    ? 0
                                    : loanRequests[index].stepsCompleted + 1,
                                true)));
                         */
                      },
                      // expiry: proposalStatus[index].expiry,
                      showExpiry:
                          proposalStatus[index].expiry == '' ? false : true,
                    ),
                  ),
                )
              : Center(
                  // child: Text(
                  //   "No Request",
                  //   style: labelStyle,
                  // ),
                  child: Image.asset(
                    'assets/images/faisal_bank_banner.png',
                    height: 400,
                    width: 400,
                  ),
                ),
        ),
        //const Spacer(),
        // Align(
        //   alignment: FractionalOffset.bottomCenter,
        //   child: Container(
        //     padding: const EdgeInsets.all(20),
        //     child: Column(
        //       children: <Widget>[
        //         const Padding(
        //           padding: EdgeInsets.only(left: 25, top: 15, bottom: 25),
        //           child: Row(
        //             children: [
        //               // Expanded(
        //               //   child: Text.rich(
        //               //     TextSpan(
        //               //       style: TextStyle(color: kPrimaryColor),
        //               //       children: [
        //               //         TextSpan(
        //               //             text:
        //               //                 'For Further assistance or query. Please contact our helpline '),
        //               //         TextSpan(
        //               //           text: '021-111-060606',
        //               //           style: TextStyle(
        //               //               color: kPrimaryColor,
        //               //               fontWeight: FontWeight.bold),
        //               //         )
        //               //       ],
        //               //     ),
        //               //   ),
        //               // ),
        //             ],
        //           ),
        //         ),
        //         // DefaultButton(
        //         //   text: openRequest ? 'Resume' : 'Apply Noor Card',
        //         //   isDisable: true,
        //         //   press: () {
        //         //     //Navigator.of(context).pop();
        //         //     //Navigator.pushNamed(context, NoorCardScreen.routeName);
        //         //     if (openRequest) {
        //         //       /*
        //         //       Navigator.of(context).push(MaterialPageRoute(
        //         //           builder: (context) => DynamicForm(
        //         //               requestId,
        //         //               stepsCompleted + 1,
        //         //               true
        //         //           )
        //         //       ));
        //         //        */
        //         //       Navigator.of(context)
        //         //           .push(MaterialPageRoute(
        //         //               builder: (context) => DynamicForm(
        //         //                     requestId,
        //         //                     stepsCompleted + 1,
        //         //                     true,
        //         //                     productType,
        //         //                   )))
        //         //           .then((_) => setState(() {
        //         //                 loanRequests.clear();
        //         //                 proposalStatus.clear();
        //         //                 requestId = 0;
        //         //                 stepsCompleted = 0;
        //         //                 openRequest = false;
        //         //                 getProposals();
        //         //               }));
        //         //     } else {
        //         //       Navigator.pushNamed(context, NoorCardScreen.routeName);
        //         //     }
        //         //   },
        //         // ),
        //         // const SizedBox(height: 10),
        //         // const ETBApplication(),
        //         // const SizedBox(height: 10),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Future<void> getLoanRequestsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      loanRequests = await databaseHelper.getAllLoanRequestInformation();
      if (loanRequests.isNotEmpty) {}
      setState(() {});
    } catch (e) {
      return null;
    }
  }

  Future<void> getProposalStatus() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      final headers = await getGenericHeaders();
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = await UserSecretStore.getSignNumber();
      String encodedPhoneNumber = Uri.encodeComponent(phoneNumber!);

      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getProposalStatus?mobileNo=$encodedPhoneNumber");
      print("Complete API URL: ${uri.toString()}");
      ReusableDialogs.showProgressDialog(context);
      var response = await client.get(uri, headers: headers);
      Navigator.pop(context);
      print(
          "Response received in getProposalStatus(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          proposalStatus.add(
            ProposalStatus(
              item['appRef'],
              item['status'],
              item['productName'] ?? 15,
              item['productName'],
            ),
          );
        }
        print("Total Proposals: ${proposalStatus.length}");
        for (ProposalStatus status in proposalStatus) {
          print("Proposal Status: ${status.productName}");
        }
        setState(() {});
      }
    } catch (e) {
      showError(e);
      print('Exception in getProposalStatus(): $e');
    }
  }

  Future<void> getProposals() async {
    try {
      await getProposalStatus();

      //await getLoanRequestsFromDB();
      // for (LoanRequestInformation item in loanRequests) {
      //   proposalStatus.add(
      //       ProposalStatus('${item.requestId}', item.status, '', 'Noor Card'));
      //   if (item.status == 'incomplete') {
      //     requestId = item.requestId;
      //     stepsCompleted = item.stepsCompleted;
      //     openRequest = true;
      //   }
      // }
    } catch (e) {
      showError(e);
      print('Exception in getProposals(): $e');
    }
  }
}
