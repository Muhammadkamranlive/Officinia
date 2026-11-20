import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _HeaderShimmer(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: const [
                  _CardShimmer(height: 120),
                  SizedBox(height: 24),
                  _CardShimmer(height: 180),
                  SizedBox(height: 24),
                  _CardShimmer(height: 100),
                  SizedBox(height: 24),
                  _CardShimmer(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            _box(44, 44, radius: 14),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(160, 16),
                  const SizedBox(height: 8),
                  _box(220, 12),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _box(44, 44, radius: 14),
          ],
        ),
      ),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  final double height;
  const _CardShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
Widget _box(double width, double height, {double radius = 8}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
