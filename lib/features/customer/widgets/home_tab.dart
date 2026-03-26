import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'banner_slider.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onCartChanged;

  const HomeTab({super.key, required this.onCartChanged});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, _) => [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.primary,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          automaticallyImplyLeading: false,
          expandedHeight: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🌶️', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GAMIKU',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Samarinda',
                      style: TextStyle(color: AppColors.white70, fontSize: 10),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: BannerSlider()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],

      body: const SizedBox(),
    );
  }
}
