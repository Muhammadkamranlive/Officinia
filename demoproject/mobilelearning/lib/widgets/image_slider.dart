import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageSlider extends StatefulWidget {
  final List<Map<String, String>> imagesWithText;
  final Function(int) onPageChanged;

  const ImageSlider({
    Key? key,
    required this.imagesWithText,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int activeIndex = 0;
  String currentText = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            onPageChanged: (int pageNo) {
              print('Card Name: ${widget.imagesWithText[pageNo]['text']}');
              setState(() {
                activeIndex = pageNo;
              });
              widget.onPageChanged(pageNo);
            },
            itemCount: widget.imagesWithText.length,
            itemBuilder: (context, index) {
              return buildImage(widget.imagesWithText[index]['image']!, index);
            },
          ),
        ),
        const SizedBox(height: 10),
        buildIndicator(),
        const SizedBox(height: 20),
        // buildTextField(),
      ],
    );
  }

  Widget buildImage(String assetImage, int index) => Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              assetImage,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 35,
            child: Text(
              currentText,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: widget.imagesWithText.length,
        effect: const ScrollingDotsEffect(dotHeight: 12, dotWidth: 12),
      );

  Widget buildTextField() => TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Type Here',
        ),
        onChanged: (value) {
          setState(() {
            currentText = value;
          });
        },
      );
}
