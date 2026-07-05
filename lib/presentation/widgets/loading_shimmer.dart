import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[300]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. skeleton metadata (avatar, author name, date)
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(width: 80, height: 12, color: Colors.white),
                    const SizedBox(width: 12.0),
                    Container(width: 40, height: 12, color: Colors.white),
                  ],
                ),

                const SizedBox(height: 10.0),

                // 2. Skeleton cover image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),

                const SizedBox(height: 12.0),

                // 3, Skeleton Title (2 rows)
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 6.0),
                Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.6,
                  color: Colors.white,
                ),
                const SizedBox(height: 10.0),

                // 4. Skeleton Description
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 4.0),
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
