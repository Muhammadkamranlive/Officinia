import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/products/components/stack_containers.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/noor_card_banner.png'),
              )),
            ),
          ),
          const Expanded(flex: 2, child: StackContainers())
        ],
    );
  }
}
