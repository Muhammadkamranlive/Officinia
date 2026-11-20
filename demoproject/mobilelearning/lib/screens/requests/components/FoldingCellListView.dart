import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell.dart';

import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/screens/loan/components/dynamic_form.dart';
import 'package:mobile_onboarding/widgets/new_application.dart';

import '../../../constants.dart';
import '../../../widgets/default_button.dart';

import '../../welcome/components/app_scroll_behavior.dart';

class FoldingCellListView extends StatefulWidget {
  const FoldingCellListView({Key? key}) : super(key: key);

  @override
  State<FoldingCellListView> createState() => _FoldingCellListViewState();
}

class _FoldingCellListViewState extends State<FoldingCellListView> {
  ScrollController _controller = new ScrollController();
  List<LoanRequestInformation> loanRequests = [];

  @override
  void initState() {
    getLoanRequestsFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Container(
          //color: Colors.white,
          child: loanRequests.length > 0
              ? ScrollConfiguration(
                  behavior: AppScrollBehavior(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _controller,
                    itemCount: loanRequests.length,
                    itemBuilder: (context, index) {
                      return SimpleFoldingCell.create(
                        frontWidget: _buildFrontWidget(index),
                        innerWidget: _buildInnerWidget(index),
                        cellSize: Size(MediaQuery.of(context).size.width, 125),
                        padding: const EdgeInsets.all(15),
                        animationDuration: const Duration(milliseconds: 300),
                        borderRadius: 10,
                        onOpen: () => print('$index cell opened'),
                        onClose: () => print('$index cell closed'),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    "No Data Found!",
                    style: labelStyle,
                  ),
                ),
        )),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                DefaultButton(
                  text: "Back to Home",
                  isDisable: true,
                  press: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 10),
                const NewApplication(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrontWidget(int index) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: kPrimaryLightColor, // Set border color
                width: 2.0), // Set border width
            borderRadius: const BorderRadius.all(
                Radius.circular(12.0)), // Set rounded corner radius
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Request ID - ${loanRequests[index].requestId}",
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: headingSize,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: TextButton(
                  onPressed: () {
                    final foldingCellState = context
                        .findAncestorStateOfType<SimpleFoldingCellState>();
                    foldingCellState?.toggleFold();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size(70, 40),
                  ),
                  child: const Text(
                    "OPEN",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildInnerWidget(int index) {
    return Builder(
      builder: (context) {
        return Container(
          color: const Color(0xFFecf2f9),
          padding: const EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Request ID - ${loanRequests[index].requestId}",
                  style: headingWhiteStyle,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Request Status: ${loanRequests[index].status.toUpperCase()}",
                  style: labelStyle,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: TextButton(
                  onPressed: () {
                    final foldingCellState = context
                        .findAncestorStateOfType<SimpleFoldingCellState>();
                    foldingCellState?.toggleFold();
                  },
                  child: Text(
                    "Close",
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(80, 40),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DynamicForm(
                            loanRequests[index].requestId,
                            loanRequests[index].status == "complete"
                                ? 0
                                : loanRequests[index].stepsCompleted + 1,
                            true,
                            productType)));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(80, 40),
                  ),
                  child: const Text(
                    "View Request",
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> getLoanRequestsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      loanRequests = await databaseHelper.getAllLoanRequestInformation();
      print("DEBUG CHECK => length of loanRequests: ${loanRequests.length}");
      setState(() {});
    } catch (e) {
      print("Exception in getLoanRequestsFromDB(): $e");
      return null;
    }
  }
}
