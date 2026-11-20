import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class ItemDetailContent extends StatelessWidget {
  final List<dynamic> itemDetails;

  ItemDetailContent({required this.itemDetails});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemDetails.length,
      itemBuilder: (context, index) {
        var item = itemDetails[index];
        return _buildDetailItem(item);
      },
    );
  }

  Widget _buildDetailItem(Map<String, dynamic> item) {
    String type = item['type'];
    String description = item['description'] ?? '';

    if (type == 'header') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(description, style: AppTextStyles.robotoMedium19PHblack),
      );
    } else if (type == 'subheader') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(description, style: AppTextStyles.robotoMedium19PHSubBlack),
      );
    } else if (type == 'Description') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Text(
          textAlign: TextAlign.justify,
          description,
          style: AppTextStyles.robotoRegular13,
        ),
      );
    } else if (type == 'Feature') {
      return ListTile(
        leading: Icon(Icons.check_circle_outline, color: Colors.grey.shade500),
        title: Text(
          description,
          style: AppTextStyles.robotoRegular13,
        ),
      );
    }

    // else if (type == 'Checkbox') {
    //   return Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Row(
    //       children: [
    //         Checkbox(value: false, onChanged: (bool? value) {}),
    //         Expanded(child: Text(description)),
    //       ],
    //     ),
    //   );
    // }
    return const SizedBox.shrink();
  }
}
