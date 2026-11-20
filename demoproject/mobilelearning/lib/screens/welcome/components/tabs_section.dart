import 'package:flutter/material.dart';

import '../../../constants.dart';

// We need stateful widget because we need to change some sate on our category
class Tabslist extends StatefulWidget {
  const Tabslist({super.key, required this.onSelectedTab});

  final void Function(int answer) onSelectedTab;

  @override
  _TabslistState createState() => _TabslistState();
}

class _TabslistState extends State<Tabslist> {
  int selectedCategory = 0;
  List<String> categories = ["Digital Account", "Product & Service"];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => buildCategory(index, context),
      ),
    );
  }

  Padding buildCategory(int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = index;
            widget.onSelectedTab(index);
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              categories[index],
              style: TextStyle(
                color: index == selectedCategory
                    ? kPrimaryColor
                    : Colors.black.withOpacity(0.4),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              height: 6,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: index == selectedCategory
                    ? kPrimaryLightColor
                    : Colors.transparent,
              ),
            )
          ],
        ),
      ),
    );
  }
}
