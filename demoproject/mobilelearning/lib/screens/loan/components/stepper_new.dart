import 'package:mobile_onboarding/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepperNew extends StatelessWidget {
  final double width;
  final totalSteps;
  final int curStep;
  final Color stepCompleteColor;
  final Color currentStepColor;
  final Color inactiveColor;
  final double lineWidth;

  StepperNew(
      {required this.width,
      required this.totalSteps,
      required this.curStep,
      required this.stepCompleteColor,
      required this.currentStepColor,
      required this.inactiveColor,
      required this.lineWidth});

  //const StepperNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 24.0,
        right: 24.0,
      ),
      width: width,
      child: Row(
        children: _steps(context),
      ),
    );
  }

  getCircleColor(i) {
    var color;
    if (i + 1 < curStep) {
      color = stepCompleteColor;
    } else if (i + 1 == curStep)
      color = currentStepColor;
    else
      color = Colors.white;
    return color;
  }

  getBorderColor(i) {
    var color;
    if (i + 1 < curStep) {
      color = stepCompleteColor;
    } else if (i + 1 == curStep)
      color = currentStepColor;
    else
      color = inactiveColor;

    return color;
  }

  getLineColor(i, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    var color =
        //curStep > i + 1 ? Colors.blue.withOpacity(0.4) : Colors.grey[200];
        //curStep > i + 1 ? Color(0xff71bf45) : Colors.grey;
        curStep > i + 1
            ? themeProvider.currentTheme.brightness == Brightness.light
                ? Color(0xff71bf45)
                : Colors.orange
            : themeProvider.currentTheme.brightness == Brightness.light
                ? Colors.grey
                : Colors.white;
    return color;
  }

  List<Widget> _steps(BuildContext context) {
    var list = <Widget>[];
    for (int i = 0; i < totalSteps; i++) {
      //colors according to state

      var circleColor = getCircleColor(i);
      var borderColor = getBorderColor(i);
      var lineColor = getLineColor(i, context);

      // step circles
      list.add(
        Container(
          width: 28.0,
          height: 28.0,
          child: getInnerElementOfStepper(i),
          decoration: new BoxDecoration(
            color: circleColor,
            borderRadius: new BorderRadius.all(new Radius.circular(25.0)),
            border: new Border.all(
              color: borderColor,
              width: 1.0,
            ),
          ),
        ),
      );

      //line between step circles
      if (i != totalSteps - 1) {
        list.add(
          Expanded(
            child: Container(
              height: lineWidth,
              color: lineColor,
            ),
          ),
        );
      }
    }

    return list;
  }

  Widget getInnerElementOfStepper(index) {
    if (index + 1 < curStep) {
      return Icon(
        Icons.check,
        color: Colors.white,
        size: 16.0,
      );
    } else if (index + 1 == curStep) {
      return Center(
        child: Text(
          '$curStep',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      );
    } else
      return Container();
  }
}
