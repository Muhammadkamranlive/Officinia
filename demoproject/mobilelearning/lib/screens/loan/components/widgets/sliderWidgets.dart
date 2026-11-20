import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/loan/components/widgets/cardDetailsDialog.dart';

class SetCardLimitWidget extends StatefulWidget {
  final double? selectedValue;

  final String cardTitle;
  final String annualFee;
  final String spendingRev;
  final String duration;
  final String fed;

  /// Range strings (API / data layer)
  final String minRange;
  final String maxRange;

  final ValueChanged<double>? onChanged;

  const SetCardLimitWidget({
    super.key,
    required this.cardTitle,
    required this.annualFee,
    required this.spendingRev,
    required this.duration,
    required this.fed,
    required this.minRange,
    required this.maxRange,
    this.selectedValue,
    this.onChanged,
  });

  @override
  State<SetCardLimitWidget> createState() => _SetCardLimitWidgetState();
}

class _SetCardLimitWidgetState extends State<SetCardLimitWidget> {
  late double _min;
  late double _max;
  late double _current;
  final _fmt = NumberFormat('#,###');

  // ---------- LIFE-CYCLE ----------
  @override
  void initState() {
    super.initState();
    _parseRange();
    _current = _min;
  }

  @override
  void didUpdateWidget(covariant SetCardLimitWidget old) {
    super.didUpdateWidget(old);

    if (old.minRange != widget.minRange || old.maxRange != widget.maxRange) {
      _parseRange();
      _current = _min; // reset to new minimum
      setState(() {}); // rebuild UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged?.call(_current);
      });
    }
  }

  // ---------- HELPERS ----------
  void _parseRange() {
    _min = double.tryParse(widget.minRange) ?? 0;
    _max = double.tryParse(widget.maxRange) ?? _min;
    if (_max < _min) {
      final t = _min;
      _min = _max;
      _max = t;
    }
  }

  double _clamp(double v) => v.clamp(_min, _max).toDouble();

  int? get _divisions {
    final diff = _max - _min;
    return diff >= 25000 ? (diff ~/ 25000) : null; // null → continuous slider
  }

  String _pkr(double v) => _fmt.format(v);

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final safeValue = _clamp(_current); // guarantees assertion safety

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Set Your Card Limit',
              style: TextStyle(
                  fontSize: 18.sp,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('PKR ${_pkr(safeValue)}',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,

              activeTickMarkColor: kPrimaryColor, // dots between min→thumb
              inactiveTickMarkColor:
                  newSecondaryColor, // dots between thumb→max

              thumbColor: kPrimaryColor,
              overlayColor: kPrimaryColor.withOpacity(0.1),

              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
            ),
            child: Slider(
              min: _min,
              max: _max,
              divisions: _divisions,
              value: safeValue,
              activeColor: kPrimaryColor,
              inactiveColor: newSecondaryColor,
              onChanged: (val) {
                setState(() => _current = _clamp(val));
                widget.onChanged?.call(_current);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bound('Min', _min),
              _bound('Max', _max),
            ],
          ),
          InfoDialogButton(
            title: widget.cardTitle,
            label: 'Fees & Waivers',
            annualFee: _pkr(double.tryParse(widget.annualFee) ?? 0),
            fed: widget.fed,
            spendingReversal: _pkr(double.tryParse(widget.spendingRev) ?? 0),
            duration: widget.duration,
          ),
        ],
      ),
    );
  }

  Widget _bound(String label, double value) => Column(
        crossAxisAlignment:
            label == 'Min' ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: kPrimaryColor)),
          Text('PKR ${_pkr(value)}',
              style: TextStyle(fontSize: 14.sp, color: kPrimaryColor)),
        ],
      );
}
