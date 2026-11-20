import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/ProfileImageService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model

class _PhotoFilter {
  final String name;
  final List<double> matrix;
  const _PhotoFilter({required this.name, required this.matrix});
}

const List<double> _identity = [
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

final List<_PhotoFilter> _filters = [
  const _PhotoFilter(name: 'Normal', matrix: _identity),
  _PhotoFilter(name: 'Clarendon', matrix: [
    1.1, 0, 0, 0, -10,
    0, 1.1, 0, 0, -10,
    0, 0, 1.2, 0, 10,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Lark', matrix: [
    1.1, 0, 0, 0, 10,
    0, 1.05, 0, 0, 5,
    0, 0, 0.9, 0, -5,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Juno', matrix: [
    1.2, 0, 0, 0, 0,
    0, 1.05, 0, 0, -5,
    0, 0, 0.9, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Reyes', matrix: [
    0.95, 0, 0, 0, 20,
    0, 0.9, 0, 0, 15,
    0, 0, 0.8, 0, 10,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Slumber', matrix: [
    0.85, 0, 0, 0, 20,
    0, 0.8, 0, 0, 10,
    0, 0, 0.7, 0, 5,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Crema', matrix: [
    1.0, 0, 0, 0, 15,
    0, 0.95, 0, 0, 10,
    0, 0, 0.85, 0, 5,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Ludwig', matrix: [
    1.05, 0, 0, 0, 5,
    0, 1.0, 0, 0, 0,
    0, 0, 0.95, 0, -5,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Aden', matrix: [
    0.9, 0, 0, 0, 10,
    0, 1.0, 0, 0, 5,
    0, 0, 1.1, 0, 10,
    0, 0, 0, 1, 0,
  ]),
  _PhotoFilter(name: 'Perpetua', matrix: [
    0.9, 0, 0, 0, 5,
    0, 1.1, 0, 0, 5,
    0, 0, 1.1, 0, 10,
    0, 0, 0, 1, 0,
  ]),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen

class RecruiterProfileScreen extends StatefulWidget {
  final Recruiter recruiter;
  const RecruiterProfileScreen({super.key, required this.recruiter});

  @override
  State<RecruiterProfileScreen> createState() =>
      _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState
    extends State<RecruiterProfileScreen> {
  final _picker = ImagePicker();
  final _imageService = ProfileImageService();
  final _repo = RecruiterRepository();

  File? _croppedFile;
  int _selectedFilter = 0;
  bool _loading = false;
  String? _currentLogoUrl; // ✅ FIX 4: tracks url locally so it updates after save

  // ✅ FIX 2: key is on the image ONLY, not the gradient ring
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentLogoUrl = widget.recruiter.logoUrl; // ✅ FIX 4
  }

  // ─── Pick + crop ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    final cropped = await _cropImage(File(picked.path));
    if (cropped == null) return;
    setState(() {
      _croppedFile = cropped;
      _selectedFilter = 0;
    });
  }

  Future<File?> _cropImage(File file) async {
    final l10n = AppLocalizations.of(context)!;
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: l10n.crop_photo,
          toolbarColor: AppColors.green,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: l10n.crop_photo,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return cropped == null ? null : File(cropped.path);
  }

  Future<void> _recrop() async {
    if (_croppedFile == null) return;
    final recropped = await _cropImage(_croppedFile!);
    if (recropped != null) setState(() => _croppedFile = recropped);
  }

  Future<File?> _captureFilteredImage() async {
    try {
      final boundary = _previewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final Uint8List bytes = byteData.buffer.asUint8List();
      final dir = Directory.systemTemp;
      final file = File(
          '${dir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    // ✅ FIX 1: allow save even when no new file — user may have only changed filter
    final hasNewFile = _croppedFile != null;
    final hasExistingPhoto = _currentLogoUrl != null && _currentLogoUrl!.isNotEmpty;
    if (!hasNewFile && !hasExistingPhoto) return;
    if (widget.recruiter.docId == null) return;

    setState(() => _loading = true);

    // ✅ FIX 3: small delay so the loading overlay actually renders before heavy work
    await Future.delayed(const Duration(milliseconds: 80));

    try {
      File? fileToUpload;

      if (_selectedFilter != 0) {
        // Has a filter applied — capture the rendered widget
        fileToUpload = await _captureFilteredImage();
      }

      // If capture failed or no filter, fall back to the local file
      fileToUpload ??= _croppedFile;

      String url;
      if (fileToUpload != null) {
        // Upload new file (new pick OR filtered version)
        url = await _imageService.uploadProfileImage(
          uid: widget.recruiter.userId,
          imageFile: fileToUpload,
        );
      } else {
        // No new file, no filter change — nothing to upload
        setState(() => _loading = false);
        Navigator.pop(context);
        return;
      }

      await _repo.update1(widget.recruiter.docId!, {'logoUrl': url});

      // ✅ FIX 4: update local url so _hasPhoto() stays correct
      setState(() => _currentLogoUrl = url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            content: Text(
              l10n.profile_picture_updated,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failed_to_update(e.toString())),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removePhoto() async {
    if (widget.recruiter.docId == null) return;
    setState(() => _loading = true);
    try {
      await _repo.update1(widget.recruiter.docId!, {'logoUrl': ''});
      setState(() {
        _croppedFile = null;
        _selectedFilter = 0;
        _currentLogoUrl = ''; // ✅ FIX 4: clear local url too
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPickOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.profile_photo_title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1),
              _SheetTile(
                icon: Icons.camera_alt_outlined,
                label: l10n.camera,
                color: Colors.black87,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              _SheetTile(
                icon: Icons.photo_library_outlined,
                label: l10n.gallery,
                color: Colors.black87,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (_hasPhoto())
                _SheetTile(
                  icon: Icons.delete_outline,
                  label: l10n.remove_photo,
                  color: Colors.red.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX 4: use local _currentLogoUrl, not stale widget model
  bool _hasPhoto() =>
      _croppedFile != null ||
      (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty);

  ImageProvider _imageProvider() {
    if (_croppedFile != null) return FileImage(_croppedFile!);
    if (_currentLogoUrl?.isNotEmpty == true)
      return NetworkImage(_currentLogoUrl!);
    return const AssetImage('assets/placeholder_avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasPhoto();
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            foregroundColor: Colors.black87,
            title: Text(
              l10n.profile_photo_title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            actions: [
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientgreen,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _loading ? null : _save,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.save_btn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // ── Large preview ─────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: hasImage
                      ? RepaintBoundary(
                          key: _previewKey,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                                _filters[_selectedFilter].matrix),
                            child: _CirclePhoto(provider: _imageProvider()),
                          ),
                        )
                      : _EmptyState(onTap: _showPickOptions, l10n: l10n),
                ),
              ),

              // ── Filter strip ──────────────────────────────────────────────
              if (hasImage) ...[
                Divider(color: Colors.grey.shade200, height: 1),
                _FilterStrip(
                  imageProvider: _imageProvider(),
                  filters: _filters,
                  selectedIndex: _selectedFilter,
                  onSelect: (i) => setState(() => _selectedFilter = i),
                  l10n: l10n,
                ),
              ],

              // ── Bottom actions ────────────────────────────────────────────
              SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  child: Row(
                    mainAxisAlignment: hasImage
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      _CircleAction(
                        icon: Icons.camera_alt,
                        label: l10n.change_action,
                        onTap: _showPickOptions,
                      ),
                      if (hasImage)
                        _CircleAction(
                          icon: Icons.crop,
                          label: l10n.recrop_action,
                          onTap: _recrop,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Loading overlay ───────────────────────────────────────────────
        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(color: AppColors.green),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CirclePhoto extends StatelessWidget {
  final ImageProvider provider;
  const _CirclePhoto({required this.provider});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.72;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradient ring matching app style
        gradient: AppColors.gradientgreen,
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: provider, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  final ImageProvider imageProvider;
  final List<_PhotoFilter> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final AppLocalizations l10n;

  const _FilterStrip({
    required this.imageProvider,
    required this.filters,
    required this.selectedIndex,
    required this.onSelect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          final filterName = filters[i].name == 'Normal' ? l10n.normal_filter : filters[i].name;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Selected: gradient border via outer container trick
                      gradient: selected ? AppColors.gradientgreen : null,
                      color: selected ? null : Colors.transparent,
                      border: selected
                          ? null
                          : Border.all(
                              color: Colors.grey.shade300, width: 2),
                    ),
                    padding: selected ? const EdgeInsets.all(2.5) : null,
                    child: ClipOval(
                      child: ColorFiltered(
                        colorFilter:
                            ColorFilter.matrix(filters[i].matrix),
                        child: Image(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    filterName,
                    style: TextStyle(
                      color: selected
                          ? AppColors.green
                          : Colors.grey.shade400,
                      fontSize: 10,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;
  const _EmptyState({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Icon(Icons.person,
                size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.gradientgreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_a_photo_outlined,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.add_profile_photo_btn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.green.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: AppColors.green, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color == Colors.black87
              ? Colors.grey.shade100
              : Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}