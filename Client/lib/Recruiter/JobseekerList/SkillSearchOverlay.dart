// lib/Recruiter/JobseekerList/SkillSearchOverlay.dart

import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';

import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────
//  PUBLIC RESULT  — what the overlay hands back to the caller
// ─────────────────────────────────────────────────────────────
class SkillFilterResult {
  final List<String> skillIds;    // selected JobOption docIds (type=skill)
  final List<String> jobTitleIds; // selected JobOption docIds (type=jobTitle)

  const SkillFilterResult({
    required this.skillIds,
    required this.jobTitleIds,
  });

  bool get isEmpty => skillIds.isEmpty && jobTitleIds.isEmpty;
}

// ─────────────────────────────────────────────────────────────
//  OVERLAY WIDGET
// ─────────────────────────────────────────────────────────────
class SkillSearchOverlay extends StatefulWidget {
  final List<String> initialSkillIds;
  final List<String> initialJobTitleIds;
  final String languageCode;

  const SkillSearchOverlay({
    super.key,
    this.initialSkillIds    = const [],
    this.initialJobTitleIds = const [],
    this.languageCode       = 'en',
  });

  /// Slides up like Google Maps search.
  /// Returns [SkillFilterResult] or null if dismissed without applying.
  static Future<SkillFilterResult?> show(
    BuildContext context, {
    List<String> initialSkillIds    = const [],
    List<String> initialJobTitleIds = const [],
    String languageCode             = 'en',
  }) {
    return Navigator.of(context).push<SkillFilterResult>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => SkillSearchOverlay(
          initialSkillIds:    initialSkillIds,
          initialJobTitleIds: initialJobTitleIds,
          languageCode:       languageCode,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end:   Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  State<SkillSearchOverlay> createState() => _SkillSearchOverlayState();
}

class _SkillSearchOverlayState extends State<SkillSearchOverlay> {
  // ── Repo ────────────────────────────────────────────────────
  final _repo = JobOptionRepository();

  // ── Data ────────────────────────────────────────────────────
  List<JobOption> _allSkills    = [];
  List<JobOption> _allJobTitles = [];
  bool _loading = true;

  // ── Selection ───────────────────────────────────────────────
  late Set<String> _selectedSkillIds;
  late Set<String> _selectedJobTitleIds;

  // ── Search ──────────────────────────────────────────────────
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus            = FocusNode();
  String _query                     = '';
  bool   _dropdownVisible           = false;

  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _selectedSkillIds    = Set.from(widget.initialSkillIds);
    _selectedJobTitleIds = Set.from(widget.initialJobTitleIds);
    _loadOptions();

    _ctrl.addListener(() {
      final v = _ctrl.text;
      setState(() {
        _query          = v;
        _dropdownVisible = v.trim().isNotEmpty;
      });
    });

    _focus.addListener(() {
      if (!_focus.hasFocus) {
        setState(() => _dropdownVisible = false);
      }
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ── Load both lists in one repo call ────────────────────────
  Future<void> _loadOptions() async {
    try {
      final all = await _repo.getAllOptions();
      if (mounted) {
        setState(() {
          _allSkills    = all.where((o) => o.type == JobOptionType.skill    && o.isActive).toList()
              ..sort((a, b) => a.order.compareTo(b.order));
          _allJobTitles = all.where((o) => o.type == JobOptionType.jobTitle && o.isActive).toList()
              ..sort((a, b) => a.order.compareTo(b.order));
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Autocomplete suggestions: skills + job titles mixed ─────
  List<_Suggestion> get _suggestions {
    if (_query.trim().isEmpty) return [];
    final q   = _query.toLowerCase();
    final out = <_Suggestion>[];

    for (final o in _allSkills) {
      final lbl = o.label(widget.languageCode);
      if (lbl.toLowerCase().contains(q) ||
          o.en.toLowerCase().contains(q)) {
        out.add(_Suggestion(option: o, type: JobOptionType.skill));
      }
    }
    for (final o in _allJobTitles) {
      final lbl = o.label(widget.languageCode);
      if (lbl.toLowerCase().contains(q) ||
          o.en.toLowerCase().contains(q)) {
        out.add(_Suggestion(option: o, type: JobOptionType.jobTitle));
      }
    }
    return out;
  }

  // ── All currently selected items (skills + job titles) ──────
  List<_Suggestion> get _selectedAll {
    final out = <_Suggestion>[];
    for (final o in _allSkills) {
      if (_selectedSkillIds.contains(o.docId)) {
        out.add(_Suggestion(option: o, type: JobOptionType.skill));
      }
    }
    for (final o in _allJobTitles) {
      if (_selectedJobTitleIds.contains(o.docId)) {
        out.add(_Suggestion(option: o, type: JobOptionType.jobTitle));
      }
    }
    return out;
  }

  bool get _hasSelection =>
      _selectedSkillIds.isNotEmpty || _selectedJobTitleIds.isNotEmpty;

  // ── Toggle a suggestion on/off ───────────────────────────────
  void _pick(_Suggestion s) {
    setState(() {
      if (s.type == JobOptionType.skill) {
        if (_selectedSkillIds.contains(s.option.docId)) {
          _selectedSkillIds.remove(s.option.docId);
        } else {
          _selectedSkillIds.add(s.option.docId!);
        }
      } else {
        if (_selectedJobTitleIds.contains(s.option.docId)) {
          _selectedJobTitleIds.remove(s.option.docId);
        } else {
          _selectedJobTitleIds.add(s.option.docId!);
        }
      }
      // Clear search field after picking — just like Google Maps
      _ctrl.clear();
      _query           = '';
      _dropdownVisible = false;
    });
  }

  void _removeSelected(_Suggestion s) {
    setState(() {
      if (s.type == JobOptionType.skill) {
        _selectedSkillIds.remove(s.option.docId);
      } else {
        _selectedJobTitleIds.remove(s.option.docId);
      }
    });
  }

  void _apply() {
    Navigator.of(context).pop(SkillFilterResult(
      skillIds:    _selectedSkillIds.toList(),
      jobTitleIds: _selectedJobTitleIds.toList(),
    ));
  }

  void _clearAll() {
    setState(() {
      _selectedSkillIds.clear();
      _selectedJobTitleIds.clear();
    });
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;
    final selected    = _selectedAll;
    final bottomPad   = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Tap-outside-to-dismiss ───────────────────────────
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Panel ────────────────────────────────────────────
          AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomPad),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle ──────────────────────────────
                  _DragHandle(),

                  // ── Search input + autocomplete dropdown ─────
                  _SearchSection(
                    ctrl:            _ctrl,
                    focus:           _focus,
                    query:           _query,
                    loading:         _loading,
                    suggestions:     suggestions,
                    dropdownVisible: _dropdownVisible,
                    selectedAll:     selected,
                    languageCode:    widget.languageCode,
                    onPick:          _pick,
                    onRemove:        _removeSelected,
                    onClearQuery: () {
                      _ctrl.clear();
                      setState(() {
                        _query           = '';
                        _dropdownVisible = false;
                      });
                      _focus.requestFocus();
                    },
                  ),

                  // ── Apply / clear row ────────────────────────
                  if (!_dropdownVisible) ...[
                    const Divider(height: 1, thickness: 0.5),
                    _BottomActionRow(
                      hasSelection: _hasSelection,
                      selectedCount:
                          _selectedSkillIds.length + _selectedJobTitleIds.length,
                      onApply:   _apply,
                      onClearAll: _clearAll,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DRAG HANDLE
// ─────────────────────────────────────────────────────────────
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SEARCH SECTION  (input + dropdown + chips)
// ─────────────────────────────────────────────────────────────
class _SearchSection extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode             focus;
  final String                query;
  final bool                  loading;
  final List<_Suggestion>     suggestions;
  final bool                  dropdownVisible;
  final List<_Suggestion>     selectedAll;
  final String                languageCode;
  final void Function(_Suggestion)  onPick;
  final void Function(_Suggestion)  onRemove;
  final VoidCallback          onClearQuery;

  const _SearchSection({
    required this.ctrl,
    required this.focus,
    required this.query,
    required this.loading,
    required this.suggestions,
    required this.dropdownVisible,
    required this.selectedAll,
    required this.languageCode,
    required this.onPick,
    required this.onRemove,
    required this.onClearQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Input row ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: focus.hasFocus
                    ? AppColors.darkGreen
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.search,
                      color: AppColors.darkGreen, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    focusNode:  focus,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(context)!.search_skills_or_positions,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 13),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 14),
                    ),
                    style: const TextStyle(fontSize: 14),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (query.isNotEmpty)
                  GestureDetector(
                    onTap: onClearQuery,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.close,
                          size: 18, color: Colors.grey.shade500),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Autocomplete dropdown ────────────────────────────
        if (dropdownVisible) ...[
          const Divider(height: 1, thickness: 0.5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: suggestions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.search_off,
                            size: 18, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.no_matches_for_query(query),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: suggestions.length,
                    itemBuilder: (_, i) {
                      final s = suggestions[i];
                      final isSelected = s.type == JobOptionType.skill
                          ? (s.option.docId != null &&
                              _isSkillSelected(s.option.docId!))
                          : (s.option.docId != null &&
                              _isJobTitleSelected(s.option.docId!));
                      return _SuggestionRow(
                        suggestion:   s,
                        isSelected:   isSelected,
                        query:        query,
                        languageCode: languageCode,
                        onTap:        () => onPick(s),
                      );
                    },
                  ),
          ),
        ],

        // ── Selected chips (shown when dropdown is closed) ───
        if (!dropdownVisible && selectedAll.isNotEmpty) ...[
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedAll
                  .map((s) => _FilterChip(
                        label:       s.option.label(languageCode),
                        type:        s.type,
                        onRemove:    () => onRemove(s),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  // Helpers called from itemBuilder — passed via closure since
  // this is a StatelessWidget and the sets live in parent state.
  // We expose simple booleans instead of passing whole sets.
  bool _isSkillSelected(String id)    => selectedAll
      .any((s) => s.type == JobOptionType.skill    && s.option.docId == id);
  bool _isJobTitleSelected(String id) => selectedAll
      .any((s) => s.type == JobOptionType.jobTitle && s.option.docId == id);
}

// ─────────────────────────────────────────────────────────────
//  SUGGESTION ROW  — single autocomplete result
// ─────────────────────────────────────────────────────────────
class _SuggestionRow extends StatelessWidget {
  final _Suggestion  suggestion;
  final bool         isSelected;
  final String       query;
  final String       languageCode;
  final VoidCallback onTap;

  const _SuggestionRow({
    required this.suggestion,
    required this.isSelected,
    required this.query,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label    = suggestion.option.label(languageCode);
    final isSkill  = suggestion.type == JobOptionType.skill;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            // ── Type icon ──────────────────────────────────
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSkill
                    ? AppColors.darkGreen.withOpacity(0.08)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSkill ? Icons.psychology_outlined : Icons.work_outline,
                size: 16,
                color: isSkill ? AppColors.darkGreen : Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),

            // ── Label + type tag ───────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightText(text: label, query: query),
                  const SizedBox(height: 2),
                  Text(
                    isSkill ? AppLocalizations.of(context)!.skill : AppLocalizations.of(context)!.position,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            // ── Check mark when selected ───────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? Icon(Icons.check_circle,
                      key: const ValueKey('on'),
                      size: 20,
                      color: AppColors.darkGreen)
                  : Icon(Icons.add_circle_outline,
                      key: const ValueKey('off'),
                      size: 20,
                      color: Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FILTER CHIP  — selected item shown below search bar
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String        label;
  final JobOptionType type;
  final VoidCallback  onRemove;

  const _FilterChip({
    required this.label,
    required this.type,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isSkill = type == JobOptionType.skill;
    final bg      = isSkill
        ? AppColors.darkGreen.withOpacity(0.09)
        : Colors.blue.shade50;
    final fg      = isSkill ? AppColors.darkGreen : Colors.blue.shade700;
    final border  = isSkill
        ? AppColors.darkGreen.withOpacity(0.3)
        : Colors.blue.shade200;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSkill ? Icons.psychology_outlined : Icons.work_outline,
            size: 13, color: fg,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: fg, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: fg),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BOTTOM ACTION ROW  — apply / clear  (inline, no header)
// ─────────────────────────────────────────────────────────────
class _BottomActionRow extends StatelessWidget {
  final bool         hasSelection;
  final int          selectedCount;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  const _BottomActionRow({
    required this.hasSelection,
    required this.selectedCount,
    required this.onApply,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 10, 16,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      child: Row(
        children: [
          // Clear — only shown when something is selected
          if (hasSelection) ...[
            OutlinedButton(
              onPressed: onClearAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context)!.clear_text, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 10),
          ],

          // Apply — always visible
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenCeladon,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                hasSelection
                    ? AppLocalizations.of(context)!.show_profiles_selected_count(selectedCount)
                    : AppLocalizations.of(context)!.show_all_profiles,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HIGHLIGHT TEXT  — bolds the matching query substring
// ─────────────────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
    }
    final lower = text.toLowerCase();
    final q     = query.toLowerCase();
    final idx   = lower.indexOf(q);
    if (idx < 0) {
      return Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: TextStyle(
              color:           AppColors.darkGreen,
              backgroundColor: AppColors.darkGreen.withOpacity(0.1),
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  INTERNAL MODEL
// ─────────────────────────────────────────────────────────────
class _Suggestion {
  final JobOption     option;
  final JobOptionType type;

  const _Suggestion({required this.option, required this.type});
}