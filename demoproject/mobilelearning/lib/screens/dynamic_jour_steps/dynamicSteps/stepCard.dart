import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class StepCard extends StatelessWidget {
  final int number;
  final String name;
  final IconData icon;
  final VoidCallback onIconPressed;

  const StepCard({
    required this.number,
    required this.name,
    required this.icon,
    required this.onIconPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      child: Card(
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                ' $number',
                style: journeyStepsStyle,
              ),
              SizedBox(
                width: 12,
              ),
              Text(name, style: journeyStepsStyle),
              Spacer(),
              IconButton(
                icon: Icon(
                  icon,
                  color: Colors.white,
                ),
                onPressed: onIconPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
