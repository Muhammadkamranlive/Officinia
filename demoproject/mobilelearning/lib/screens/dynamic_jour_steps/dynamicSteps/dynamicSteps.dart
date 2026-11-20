import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/dynamic_jour_steps/dynamicSteps/stepCard.dart';
import 'package:mobile_onboarding/screens/loan/components/dynamic_form.dart';

class dynamicStepsList extends StatefulWidget {
  @override
  _dynamicStepsListState createState() => _dynamicStepsListState();
}

class _dynamicStepsListState extends State<dynamicStepsList> {
  late Future<List<StepItem>> stepsFuture;

  @override
  void initState() {
    super.initState();
    stepsFuture = loadSteps();
  }

  Future<List<StepItem>> loadSteps() async {
    String jsonString =
        await rootBundle.loadString('assets/json/noor_cardJourney.json');

    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    List<StepItem> steps = [];

    if (productType == 0) {
      List<dynamic> stepsJson = jsonData['noorCard_steps'];
      steps = stepsJson.map((stepJson) => StepItem.fromJson(stepJson)).toList();
    } else if (productType == 2) {
      List<dynamic> stepsJson = jsonData['account_opening'];
      steps = stepsJson.map((stepJson) => StepItem.fromJson(stepJson)).toList();
    } else if (productType == 3) {
      List<dynamic> stepsJson = jsonData['account_opening'];
      steps = stepsJson.map((stepJson) => StepItem.fromJson(stepJson)).toList();
    } else if (productType == 4) {
      List<dynamic> stepsJson = jsonData['account_opening'];
      steps = stepsJson.map((stepJson) => StepItem.fromJson(stepJson)).toList();
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kPrimaryGradientColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FutureBuilder<List<StepItem>>(
          future: stepsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading steps'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No steps found'));
            } else {
              List<StepItem> steps = snapshot.data!;
              return AnimatedList(
                initialItemCount: steps.length,
                itemBuilder: (context, index, animation) {
                  StepItem step = steps[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: StepCard(
                      number: step.number,
                      name: step.name,
                      icon: getIconByIndex(index),
                      onIconPressed: () {
                        if (step.number == 0) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DynamicForm(0, 0, false, productType),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  IconData getIconByIndex(int index) {
    // Get the icon list based on productType
    final iconsList = getIconsList();

    // Modify the list by prepending Icons.arrow_forward
    final modifiedIconsList = [
      Icons.arrow_forward,
      ...iconsList,
    ];

    // Ensure the index is within bounds
    if (index < 0 || index >= modifiedIconsList.length) {
      throw IndexError(index, modifiedIconsList);
    }

    // Return the icon at the specified index
    return modifiedIconsList[index];
  }

// Function to get the appropriate icon list based on productType
  List<IconData> getIconsList() {
    if (productType == 4) {
      return accountOpeningJourneyIconsList;
    } else {
      return noorCardJourneyIconsList;
    }
  }
}

//   IconData getIconData(String iconName) {
//     switch (iconName) {
//       case 'Arrow':
//         return Icons.arrow_forward_ios;
//       case 'work':
//         return Icons.work;
//       case 'credit_card':
//         return Icons.credit_card;
//       case 'person':
//         return Icons.person;
//       case 'camera_alt':
//         return Icons.camera_alt;
//       case 'home':
//         return Icons.home;
//       case 'description':
//         return Icons.description;
//       case 'check_circle':
//         return Icons.check_circle;
//       default:
//         return Icons.help_outline;
//     }
//   }
// }

class StepItem {
  final int number;
  final String name;
  final String icon;

  StepItem({required this.number, required this.name, required this.icon});

  factory StepItem.fromJson(Map<String, dynamic> json) {
    return StepItem(
      number: json['number'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}
