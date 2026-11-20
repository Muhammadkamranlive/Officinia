// ignore_for_file: library_private_types_in_public_api

//import 'package:fb_uiux/widgets/appdata/ConstantsColors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class CustomSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double>? onChanged;

  const CustomSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _currentSliderValue,
          max: widget.max,
          min: widget.min,
          divisions: widget.divisions,
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
            });
            widget.onChanged?.call(value);
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min',
                style: TextStyle(color: kLabelColor),
              ),
              Text(
                'Max',
                style: TextStyle(color: kLabelColor),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PKR ${widget.min.toStringAsFixed(0)}',
                style: const TextStyle(color: kLabelColor),
              ),
              Text(
                'PKR ${widget.max.toStringAsFixed(0)}',
                style: const TextStyle(color: kLabelColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
