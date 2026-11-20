import 'package:flutter/material.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';

import 'RequestListView.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConnectivityBanner(),
        Flexible(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,

            decoration: const BoxDecoration(
              color: Color(0xFFf3f3f3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: const RequestListView(),
            //child: FoldingCellListView(),
          ),
        ),
      ],
    );
  }
}
