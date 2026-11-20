import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderlessDropdown extends StatefulWidget {
  /// Items to show in the dropdown menu. Duplicate strings are ignored.
  final List<String> items;

  /// Placeholder text shown before a selection is made.
  final String hint;

  /// Floating label displayed above the dropdown.
  final String label;

  /// Callback whenever the user selects an item.
  final ValueChanged<String?> onChanged;

  /// The currently‑selected value (can be null for an unselected state).
  final String? selectedValue;

  /// Validation error message shown when no value is selected.
  final String errorMessage;

  const BorderlessDropdown({
    Key? key,
    required this.items,
    required this.hint,
    required this.label,
    required this.onChanged,
    this.selectedValue,
    this.errorMessage = 'This field is required',
  }) : super(key: key);

  @override
  State<BorderlessDropdown> createState() => _BorderlessDropdownState();
}

class _BorderlessDropdownState extends State<BorderlessDropdown> {
  String? _currentValue;

  @override
  void initState() {
    super.initState();
    _syncCurrentValue();
  }

  @override
  void didUpdateWidget(covariant BorderlessDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.selectedValue != widget.selectedValue) {
      _syncCurrentValue();
    }
  }

  /// Ensures `_currentValue` is one of the (unique) items, else `null`.
  void _syncCurrentValue() {
    final uniqueItems = widget.items.toSet();
    if (widget.selectedValue != null &&
        uniqueItems.contains(widget.selectedValue)) {
      _currentValue = widget.selectedValue;
    } else if (!uniqueItems.contains(_currentValue)) {
      _currentValue = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using FormField so we can participate in the parent Form's validation cycle.
    return FormField<String>(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.errorMessage;
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        final bool hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: widget.label,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: hasError ? Colors.red : Colors.grey,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _currentValue,
                  hint: Text(widget.hint),
                  items: _buildMenuItems(),
                  onChanged: (val) {
                    setState(() => _currentValue = val);
                    state.didChange(val);
                    widget.onChanged(val);
                  },
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 4),
              Text(
                state.errorText ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Builds dropdown menu items with a horizontal divider after each **unique**
  /// item, except the last one. Duplicate values are dropped.
  List<DropdownMenuItem<String>> _buildMenuItems() {
    final List<DropdownMenuItem<String>> menuItems = [];
    final Set<String> seen = <String>{};
    final uniqueList = widget.items.where((e) => seen.add(e)).toList();

    for (int i = 0; i < uniqueList.length; i++) {
      final String item = uniqueList[i];
      menuItems.add(
        DropdownMenuItem<String>(
          value: item,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item),
              if (i != uniqueList.length - 1)
                const Divider(height: 1, thickness: 1),
            ],
          ),
        ),
      );
    }
    return menuItems;
  }
}
