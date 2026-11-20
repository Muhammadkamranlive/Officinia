import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveInstructionTable extends StatelessWidget {
  const ResponsiveInstructionTable({super.key});

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
                      width: 50.w,
                      height: 50.h,
                      child: Image.asset(
                        "assets/icon_Images/Selfie.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Sit in a bright area to perform facial recognition.',
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
                      child: Image.asset("assets/icon_Images/ID_Card.png"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Have your Original CNIC/SNIC/NICOP.',
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
                      child: Image.asset("assets/icon_Images/Documents.png"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Salary Slips or Complete Business Proof with Bank Statement of Last 6 Months',
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
