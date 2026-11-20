import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveCnicInstructionTable extends StatelessWidget {
  const ResponsiveCnicInstructionTable({super.key});

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
                      width: 40.w, // matches height for a square icon
                      height: 40.h,
                      child: Image.asset(
                        "assets/icon_Images/Bright.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Kindly make sure you are in a bright space',
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
                      child: Image.asset("assets/icon_Images/ID.png"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Place your ID horizontally within the frame',
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
                      child: Image.asset("assets/icon_Images/Scan.png"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Scan your ID front & back side',
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
