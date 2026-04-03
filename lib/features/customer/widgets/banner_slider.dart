import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});
  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final _ctrl = PageController();
  int _cur = 0;

  static const _banners = [
    _BannerData(
      title: 'Gami Bebek Spesial 🦆',
      subtitle: 'Rasa autentik, harga terjangkau',
      tag: 'TERPOPULER',
      tagColor: AppColors.accent,
      imageUrl:
          'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600&q=80',
      gradientStart: AppColors.primary,
      gradientEnd: AppColors.primaryDark,
    ),
    _BannerData(
      title: 'Sambal Bakar Iga Premium 🥩',
      subtitle: 'Sensasi pedas nampol abis',
      tag: 'HOT 🔥',
      tagColor: AppColors.bannerRed2Start,
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&q=80',
      gradientStart: AppColors.bannerRed2Start,
      gradientEnd: AppColors.bannerRed2End,
    ),
    _BannerData(
      title: 'Mie Gami, Cuma 25k! 🍜',
      subtitle: 'Beli 2 gratis es teh manis',
      tag: 'PROMO',
      tagColor: AppColors.accent,
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
      gradientStart: AppColors.bannerGoldStart,
      gradientEnd: AppColors.bannerGoldEnd,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      _ctrl.animateToPage(
        (_cur + 1) % _banners.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _cur = i),
            itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _cur ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _cur ? AppColors.primary : AppColors.textLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title, subtitle, tag, imageUrl;
  final Color tagColor, gradientStart, gradientEnd;
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.imageUrl,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: data.gradientStart),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: data.gradientStart,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.white38),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                data.gradientStart.withValues(alpha: 0.85),
                data.gradientEnd.withValues (alpha: 0.5),
                AppColors.bannerCircle,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: data.tagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.tag,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  shadows: [
                    Shadow(
                      color: AppColors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.subtitle,
                style: const TextStyle(
                  color: AppColors.white70,
                  fontSize: 11,
                  shadows: [Shadow(color: AppColors.black26, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Pesan Sekarang →',
                  style: TextStyle(
                    color: data.gradientStart,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
