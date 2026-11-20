import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/screens/loan/components/dynamic_form.dart';
import 'package:mobile_onboarding/screens/requests/components/request_card.dart';
import 'package:mobile_onboarding/widgets/new_application.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../model/proposal_status.dart';
import '../../../widgets/default_button.dart';
import '../../../widgets/etb_application.dart';

import '../../noorcard/noor_card_screen.dart';

import 'package:http/http.dart' as http;

class RequestListView extends StatefulWidget {
  const RequestListView({Key? key}) : super(key: key);

  @override
  State<RequestListView> createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> with RouteAware {
  ScrollController _controller = ScrollController();
  List<LoanRequestInformation> loanRequests = [];
  List<ProposalStatus> proposalStatus = [];
  int requestId = 0;
  int stepsCompleted = 0;
  bool openRequest = false;
  bool _isLoading = false; // Add this line

  @override
  void initState() {
    super.initState();
    getProposals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the RouteObserver to listen for navigation events
    RouteObserver<ModalRoute<void>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe from the RouteObserver to prevent memory leaks
    RouteObserver<ModalRoute<void>>().unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when this screen becomes visible again
    getProposals();
  }

  // Future<void> getLoanRequestsFromDB() async {
  //   try {
  //     DatabaseHelper databaseHelper = DatabaseHelper();
  //     loanRequests = await databaseHelper.getAllLoanRequestInformation();
  //     print(loanRequests.toString());
  //   } catch (e) {
  //     print('Exception in getLoanRequestsFromDB(): $e');
  //   }
  // }

  // Future<void> getProposalStatus() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String? phoneNumber = prefs.getString('sign_in_number');

  //     var client = http.Client();
  //     var uri = Uri.parse(
  //         "${getApiBaseUrl()}/LOS/getProposalStatus?mobileNo=$phoneNumber");
  //     print("Complete API URL: ${uri.toString()}");
  //     var response = await client.get(uri);
  //     print(
  //         "Response received in getProposalStatus(): ${response.body.toString()}");
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> nTypes =
  //           jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  //       List<dynamic> dataList = nTypes['data'];
  //       print("Length of Data List: ${dataList.length}");
  //       print("Data List: ${dataList.toString()}");
  //       for (var item in dataList) {
  //         proposalStatus.add(ProposalStatus(item['appRef'], item['status'],
  //             item['expiry'] ?? '15', item['productName']));
  //       }
  //       print("Total Proposals: ${proposalStatus.length}");
  //       for (ProposalStatus status in proposalStatus) {
  //         print("Proposal Status: ${status.productName}");
  //       }
  //     }
  //   } catch (e) {
  //     print('Exception in getProposalStatus(): $e');
  //   }
  // }

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
        }
      }
    } catch (e) {
      showError(e);
      print('Exception in getProposals(): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : loanRequests.isNotEmpty
                    ? ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        controller: _controller,
                        itemCount: proposalStatus.length,
                        itemBuilder: (context, index) => RequestCard(
                          id: int.parse(proposalStatus[index].appRef),
                          status: proposalStatus[index].status,
                          productName: proposalStatus[index]
                                      .productName
                                      .length >=
                                  15
                              ? '${proposalStatus[index].productName.substring(0, 15)} ...'
                              : proposalStatus[index].productName,
                          press: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DynamicForm(
                                      loanRequests[index].requestId,
                                      loanRequests[index].status == "complete"
                                          ? 0
                                          : loanRequests[index].stepsCompleted +
                                              1,
                                      true,
                                      productType,
                                    )));

                            print(proposalStatus[index].productName.length);
                          },
                          // expiry: proposalStatus[index].expiry,
                          showExpiry: proposalStatus[index].expiry.isNotEmpty,
                        ),
                      )
                    : Center(
                        child: Text(
                          "No Request Found!",
                          style:
                              TextStyle(color: kPrimaryColor, fontSize: 20.sp),
                        ),
                      ),
          ),
          Align(
            // alignment: FractionalOffset.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 15, top: 15, bottom: 25, right: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(color: kPrimaryColor),
                              children: [
                                TextSpan(
                                    text:
                                        'For further assistance or queries, please contact our helpline '),
                                TextSpan(
                                  text: '021-111-060606',
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DefaultButton(
                    text: openRequest ? 'Resume' : 'Apply Noor Card',
                    isDisable: true,
                    press: () {
                      if (openRequest) {
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
                      } else {
                        Navigator.pushNamed(context, NoorCardScreen.routeName);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  // const ETBApplication(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
