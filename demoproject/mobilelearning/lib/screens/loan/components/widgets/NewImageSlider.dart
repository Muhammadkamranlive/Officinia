import 'dart:convert';
import 'package:flutter/material.dart';

class RemoteImageSliderWidget extends StatefulWidget {
  const RemoteImageSliderWidget({
    Key? key,
    required this.items,
    this.onMinMaxChanged,
  }) : super(key: key);

  final List<dynamic> items;
  final void Function(
      String cardLabel,
      String Pvalue,
      String minAmount,
      String maxAmount,
      String annualFee,
      String fed,
      String spendingReversal,
      String duration)? onMinMaxChanged;

  @override
  State<RemoteImageSliderWidget> createState() =>
      _RemoteImageSliderWidgetState();
}

class _RemoteImageSliderWidgetState extends State<RemoteImageSliderWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (widget.onMinMaxChanged != null && widget.items.isNotEmpty) {
      final currentItem = widget.items[_currentIndex];
      final annualFee = currentItem['annualFee']?.toString() ?? '';
      final fed = currentItem['fed']?.toString() ?? '';
      final spendingReversal =
          currentItem['spendingReversal']?.toString() ?? '';
      final cardlabel = currentItem['label']?.toString() ?? '';
      final pValue = currentItem['value']?.toString() ?? '';
      final duration = currentItem['duration']?.toString() ?? '';
      final minAmount = currentItem['minAmount']?.toString() ?? '';
      final maxAmount = currentItem['maxAmount']?.toString() ?? '';
      widget.onMinMaxChanged!(cardlabel, minAmount, maxAmount, annualFee, fed,
          spendingReversal, duration, pValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If needed, check widget.items.isEmpty and return a placeholder
    if (widget.items.isEmpty) {
      return const Center(child: Text('No images to display'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PageView slider
        SizedBox(
          height: 200, // adjust as needed
          child: PageView.builder(
            key: const PageStorageKey('product_type_slider'),
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final base64String = item['image'] ?? '';
              final imageBytes =
                  base64String.isNotEmpty ? base64Decode(base64String) : null;

              if (imageBytes == null || imageBytes.isEmpty) {
                return const Center(child: Text('No Image'));
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),

        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.blue : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}
