import 'dart:math';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:timelines/timelines.dart';

const kTileHeight = 50.0;

const completeColor = newSecondaryColor;
const inProgressColor = Color(0xff5ec792);
const todoColor = kPrimaryColor;

class ProcessTimelineNew extends StatelessWidget {
  List<String> processes;
  int currentIndex;
  ProcessTimelineNew({required this.processes, required this.currentIndex});

  late final List<String> _processes = processes;
  late final int _processIndex = currentIndex;

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  List<IconData> getIconsList() {
    if (productType == 4) {
      return accountOpeningJourneyIconsList;
    } else {
      return noorCardJourneyIconsList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icons = getIconsList();
    print('Process Index: $_processIndex');
    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        direction: Axis.horizontal,
        connectorTheme: const ConnectorThemeData(
          space: 30.0,
          thickness: 5.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemExtentBuilder: (_, __) =>
            MediaQuery.of(context).size.width / _processes.length,
        // oppositeContentsBuilder: (context, index) {
        //   return Padding(
        //     padding: const EdgeInsets.only(bottom: 5.0),
        //     child: Image.asset(
        //       'assets/images/process_timeline/status${index + 1}.png',
        //       width: 30.0,
        //       color: getColor(index),
        //     ),
        //     // child: Icon(
        //     //   icons[index %
        //     //       icons
        //     //           .length], // Ensure it loops if there are more steps than icons
        //     //   size: 20.0,
        //     //   color: getColor(index),
        //     // ),
        //   );
        // },
        contentsBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              // _processes[index]
              //     .split('_')
              //     .map((word) => word.capitalize())
              //     .join(' '),
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: getColor(index),
              ),
            ),
          );
        },
        indicatorBuilder: (_, index) {
          var color;
          var child;
          if (index == _processIndex) {
            color = inProgressColor;
            /*child = Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );*/
            child = Center(
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (index < _processIndex) {
            color = completeColor;
            child = const Icon(
              Icons.check,
              color: Colors.white,
              size: 15.0,
            );
          } else {
            color = todoColor;
          }

          if (index <= _processIndex) {
            return Stack(
              children: [
                CustomPaint(
                  size: const Size(30.0, 30.0),
                  painter: _BezierPainter(
                    color: color,
                    drawStart: index > 0,
                    drawEnd: index < _processIndex,
                  ),
                ),
                DotIndicator(
                  size: 30.0,
                  color: color,
                  child: child,
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                CustomPaint(
                  size: const Size(15.0, 15.0),
                  painter: _BezierPainter(
                    color: color,
                    drawEnd: index < _processes.length - 1,
                  ),
                ),
                OutlinedDotIndicator(
                  borderWidth: 4.0,
                  color: color,
                ),
              ],
            );
          }
        },
        connectorBuilder: (_, index, type) {
          if (index > 0) {
            if (index == _processIndex) {
              final prevColor = getColor(index - 1);
              final color = getColor(index);
              List<Color> gradientColors;
              if (type == ConnectorType.start) {
                gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
              } else {
                gradientColors = [
                  prevColor,
                  Color.lerp(prevColor, color, 0.5)!
                ];
              }
              return DecoratedLineConnector(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                ),
              );
            } else {
              return SolidLineConnector(
                color: getColor(index),
              );
            }
          } else {
            return null;
          }
        },
        itemCount: _processes.length,
      ),
    );
  }
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
