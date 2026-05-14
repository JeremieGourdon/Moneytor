import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerAccountCard extends StatelessWidget {
  const ShimmerAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 60, height: 12, color: Colors.white),
              ],
            ),
            Container(width: 80, height: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class ShimmerHeroCard extends StatelessWidget {
  const ShimmerHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!, // Dark shimmer for the hero card
      highlightColor: Colors.grey[800]!,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
