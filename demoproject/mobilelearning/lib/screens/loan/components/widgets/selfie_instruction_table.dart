import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveSelfieInstructionTable extends StatelessWidget {
  const ResponsiveSelfieInstructionTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FractionallySizedBox(
          widthFactor: 1, // ← table will be full width
          child: Table(
            // Center all cell contents vertically
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(
              top: BorderSide.none,
              bottom: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
              horizontalInside: BorderSide(color: Colors.grey.shade300),
              verticalInside: BorderSide(color: Colors.grey.shade300),
            ),
            columnWidths: const {
              0: FractionColumnWidth(0.1), // 10% of table width
              1: FractionColumnWidth(0.8), // 80% of table width
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 50.w, // matches height for a square icon
                      height: 50.h,
                      child: Image.asset(
                        "assets/icon_Images/Bright.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Sit in a bright area for better results & avoid direct sunlight',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: Image.asset("assets/icon_Images/Capture.png"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Look directly into the camera',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: Image.asset("assets/icon_Images/NO_glasses.png"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Please remove sunglasses or mask',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
