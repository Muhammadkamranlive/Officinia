import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/widgets/customDropDown.dart';
import 'package:mobile_onboarding/widgets/newUI_TF_DF.dart';

/// Global storage that survives navigation so the draft can be resumed.
final Map<String, dynamic> CF1_values = {};

/// Key that stores *how many* groups of sub‑fields were on screen.
const String _groupsKey = 'fin_facility_groupCount';

/// Helper to build a unique map‑key per repeated group field.
String _mkKey(String fieldId, int groupIdx) => '${fieldId}_$groupIdx';

class DynamicRadioWidget extends StatefulWidget {
  final List<dynamic> rawListItems;
  final List<dynamic> rawListItemsDetails;
  final String label;

  /// Optional external validator (e.g. non‑empty, regex etc.)
  final FormFieldValidator<String>? validator;

  const DynamicRadioWidget({
    super.key,
    required this.rawListItems,
    required this.rawListItemsDetails,
    this.label = 'Availing any financing facility?',
    this.validator,
  });

  @override
  State<DynamicRadioWidget> createState() => DynamicRadioWidgetState();
}

class DynamicRadioWidgetState extends State<DynamicRadioWidget>
    with AutomaticKeepAliveClientMixin {
  // -------------------- STATE ---------------------------------------------
  String? _selectedOption; // current radio value
  late final List<String> _radioOptions; // ["Yes", "No"]
  late final List<List<Map<String, dynamic>>> _subFieldTemplate;
  final List<List<Map<String, dynamic>>> _groups = []; // repeated sets
  final Map<String, TextEditingController> _controllers = {}; // key → ctrl
  String? _radioError; // validation msg

  // -------------------- INIT ----------------------------------------------
  @override
  void initState() {
    super.initState();

    _radioOptions = widget.rawListItems.cast<String>().toList();
    _subFieldTemplate = widget.rawListItemsDetails.map((raw) {
      return (raw as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }).toList();

    // restore radio selection
    final savedRadio = CF1_values['radio_selected_option'] as String?;
    if (savedRadio != null && _radioOptions.contains(savedRadio)) {
      _selectedOption = savedRadio;
    } else if (_radioOptions.length > 1) {
      _selectedOption = _radioOptions[1];
      CF1_values['radio_selected_option'] = _selectedOption;
    }

    // restore groups
    final savedCount = CF1_values[_groupsKey] as int? ?? 0;
    if (_selectedOption == _radioOptions.first) {
      final count = savedCount == 0 ? 1 : savedCount;
      for (int i = 0; i < count; i++) {
        _groups.add(_restoreOrCloneGroup(i));
      }
    }
  }

  // -------------------- KEEP‑ALIVE ----------------------------------------
  @override
  bool get wantKeepAlive => true;

  // -------------------- UI -------------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context); // keep‑alive requirement

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildRadioCard(),
        const SizedBox(height: 16),
        if (_selectedOption == _radioOptions.first) _buildGroupsSection(),
      ],
    );
  }

  // -------------------- RADIO ---------------------------------------------
  Widget _buildRadioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: newSecondaryColor)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 32.w,
            children:
                _radioOptions.map((option) => _buildRadio(option)).toList(),
          ),
          if (_radioError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_radioError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildRadio(String option) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: option,
          groupValue: _selectedOption,
          activeColor: newSecondaryColor,
          onChanged: (v) {
            setState(() {
              _selectedOption = v;
              CF1_values['radio_selected_option'] = v;
              _radioError = null;

              if (_selectedOption == _radioOptions.first) {
                if (_groups.isEmpty) _groups.add(_cloneGroup());
              } else {
                _groups.clear();
                CF1_values[_groupsKey] = 0;
              }
            });
          },
        ),
        Text(option),
      ],
    );
  }

  // -------------------- GROUPS --------------------------------------------
  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _groups.length; i++) _buildGroup(i),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_groups.isNotEmpty)
              ElevatedButton(
                style: _btnStyle,
                onPressed: () {
                  setState(() {
                    _groups.removeLast();
                    CF1_values[_groupsKey] = _groups.length;
                  });
                },
                child: const Text('Remove',
                    style: TextStyle(color: newSecondaryColor)),
              ),
            ElevatedButton(
              style: _btnStyle,
              onPressed: () {
                setState(() {
                  _groups.add(_cloneGroup());
                  CF1_values[_groupsKey] = _groups.length;
                });
              },
              child: const Text('+ Add',
                  style: TextStyle(color: newSecondaryColor)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroup(int idx) {
    final selProduct =
        CF1_values[_mkKey('product_under_type', idx)]?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _groups[idx].mapIndexed((fieldIdx, map) {
        if (map['fieldClassID'] == 'tenure' && (selProduct == 'Credit Card')) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildField(map, idx, fieldIdx),
        );
      }).toList(),
    );
  }

  Widget _buildField(Map<String, dynamic> map, int g, int f) {
    final type = (map['fieldType'] ?? '').toString().toLowerCase();
    switch (type) {
      case 'picker':
        return _buildDropdown(map, g, f);
      case 'entry':
        return _buildTextField(map, g, f);
      case 'switch':
        return _buildSwitch(map, g, f);
      default:
        return Text('Unsupported fieldType: $type');
    }
  }

  // -------------------- DROPDOWN -----------------------------------------
  Widget _buildDropdown(Map<String, dynamic> map, int g, int f) {
    final items = (map['listItems'] as List).cast<String>();
    final placeholder = map['fieldPlaceholder']?.toString() ?? '';
    final fieldId = map['fieldClassID']?.toString() ?? '';
    final key = _mkKey(fieldId, g);
    final selected = _groups[g][f]['userValue']?.toString() ?? '';

    return DropDownBu(
      items: items,
      hint: placeholder,
      label: placeholder,
      selectedValue: selected.isEmpty ? null : selected,
      validator: (val) {
        if ((val == null || val.isEmpty)) return 'Please select $placeholder';
        return widget.validator?.call(val);
      },
      onChanged: (val) {
        setState(() {
          final v = val ?? '';
          _groups[g][f]['userValue'] = v;
          CF1_values[key] = v;
          if (fieldId == 'product_under_type') _maybeClearTenure(g, v);
        });
      },
    );
  }

  // -------------------- TEXT FIELD ---------------------------------------
  Widget _buildTextField(Map<String, dynamic> map, int g, int f) {
    final placeholder = map['fieldPlaceholder']?.toString() ?? '';
    final fieldId = map['fieldClassID']?.toString() ?? '';
    final key = _mkKey(fieldId, g);
    final init = _groups[g][f]['userValue']?.toString() ?? '';

    final ctrl =
        _controllers.putIfAbsent(key, () => TextEditingController(text: init));
    if (ctrl.text != init) ctrl.text = init;

    final isTenure = fieldId == 'tenure';
    final selProduct = CF1_values[_mkKey('product_under_type', g)]?.toString();
    final disabled = isTenure && (selProduct == 'Credit Card');

    // optional list of input formatters provided via JSON
    List<TextInputFormatter>? formatters;
    if (map['inputFormatters'] != null) {
      final raw = map['inputFormatters'];
      formatters = [];
      final List<dynamic> fmtList = raw is List ? raw : [raw];
      for (var f in fmtList) {
        switch (f) {
          case 'digitsOnly':
            formatters.add(FilteringTextInputFormatter.digitsOnly);
            break;
          // add more cases if needed (e.g. lettersOnly)
        }
      }
    }
    return AbsorbPointer(
      absorbing: disabled,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: NewCustomTextField_DF(
          controller: ctrl,
          labelText: placeholder,
          hintText: placeholder,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          inputType: disabled
              ? TextInputType.none
              : (map['fieldKeyboardType'] == 'number'
                  ? TextInputType.number
                  : TextInputType.text),
          validator: disabled
              ? null
              : (val) {
                  if ((val == null || val.isEmpty))
                    return 'Please Enter $placeholder';
                  return widget.validator?.call(val);
                },
          onChanged: (val) {
            _groups[g][f]['userValue'] = val;
            CF1_values[key] = val;
          },
        ),
      ),
    );
  }

  // -------------------- SWITCH -------------------------------------------
  Widget _buildSwitch(Map<String, dynamic> map, int g, int f) {
    final placeholder = map['fieldPlaceholder']?.toString() ?? '';
    final fieldId = map['fieldClassID']?.toString() ?? '';
    final key = _mkKey(fieldId, g);
    final value = _groups[g][f]['userValue'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(placeholder,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Switch(
          value: value,
          onChanged: (v) {
            setState(() {
              _groups[g][f]['userValue'] = v;
              CF1_values[key] = v.toString();
            });
          },
        ),
      ],
    );
  }

  // -------------------- HELPERS ------------------------------------------
  List<Map<String, dynamic>> _cloneGroup() =>
      _subFieldTemplate.first.map((e) => Map<String, dynamic>.from(e)).toList();

  List<Map<String, dynamic>> _restoreOrCloneGroup(int idx) {
    return _subFieldTemplate.first.map((item) {
      final clone = Map<String, dynamic>.from(item);
      final fieldId = clone['fieldClassID']?.toString() ?? '';
      final key = _mkKey(fieldId, idx);
      if (CF1_values.containsKey(key)) clone['userValue'] = CF1_values[key];
      return clone;
    }).toList();
  }

  void _maybeClearTenure(int g, String newProd) {
    if (newProd == 'Credit Card') {
      for (final field in _groups[g]) {
        if (field['fieldClassID'] == 'tenure') {
          field['userValue'] = '';
          CF1_values[_mkKey('tenure', g)] = '';
          _controllers[_mkKey('tenure', g)]?.text = '';
          break;
        }
      }
    }
  }

  // -------------------- VALIDATION WHOLE WIDGET --------------------------
  String? validateAll() {
    if (_selectedOption == null) _radioError = 'Please select an option.';

    if (_selectedOption == _radioOptions.first) {
      for (int g = 0; g < _groups.length; g++) {
        for (final field in _groups[g]) {
          final val = field['userValue']?.toString() ?? '';
          final placeholder = field['fieldPlaceholder']?.toString() ?? '';
          final type = field['fieldType']?.toString().toLowerCase() ?? '';

          if (field['fieldClassID'] == 'tenure') {
            final prod =
                CF1_values[_mkKey('product_under_type', g)]?.toString();
            if (prod == 'Credit Card') continue;
          }

          if (val.isEmpty) {
            return type == 'picker'
                ? 'Please select $placeholder'
                : 'Please enter $placeholder';
          }

          final external = widget.validator?.call(val);
          if (external != null) return external;
        }
      }
    }
    return _radioError;
  }

  // -------------------- STYLE --------------------------------------------
  ButtonStyle get _btnStyle => ElevatedButton.styleFrom(
        elevation: 0,
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}

// Iterable extension: map with index
extension _Idx<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int idx, E e) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}
