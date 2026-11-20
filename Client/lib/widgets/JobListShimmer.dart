import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius radius;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
        ),
      ),
    );
  }
}

class JobListShimmer extends StatelessWidget {
  const JobListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => const JobCardShimmer(),
    );
  }
}

class DashboardHeaderShimmer extends StatelessWidget {
  const DashboardHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const ShimmerBox(
            height: 44,
            width: 44,
            radius: BorderRadius.all(Radius.circular(14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 16, width: 180),
                SizedBox(height: 6),
                ShimmerBox(height: 12, width: 220),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const ShimmerBox(
            height: 44,
            width: 44,
            radius: BorderRadius.all(Radius.circular(14)),
          ),
        ],
      ),
    );
  }
}
class JobCardShimmer extends StatelessWidget {
  const JobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(
                height: 40,
                width: 40,
                radius: BorderRadius.all(Radius.circular(20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(height: 14, width: 120),
                    SizedBox(height: 6),
                    ShimmerBox(height: 12, width: 160),
                  ],
                ),
              ),
              const ShimmerBox(height: 20, width: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              ShimmerBox(height: 12, width: 120),
              Spacer(),
              ShimmerBox(height: 22, width: 70),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              ShimmerBox(height: 36, width: 110),
              Spacer(),
              ShimmerBox(height: 14, width: 80),
              Spacer(),
              ShimmerBox(height: 12, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}
