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
      'Gami Bebek Spesial 🦆',
      'Rasa autentik, harga terjangkau',
      AppColors.primary,
      AppColors.bannerRed1End,
    ),
    _BannerData(
      'Sambal Bakar Iga Premium 🥩',
      'Sensasi pedas nampol abis',
      AppColors.bannerRed2Start,
      AppColors.bannerRed2End,
    ),
    _BannerData(
      'Mie Gami, Cuma 25k! 🍜',
      'Beli 2 gratis es teh',
      AppColors.bannerGoldStart,
      AppColors.bannerGoldEnd,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      _ctrl.animateToPage(
        (_cur + 1) % _banners.length,
        duration: const Duration(milliseconds: 400),
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
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _cur = i),
            itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
          ),
          _buildIndicators(),
        ],
      ),
    );
  }

  Widget _buildIndicators() => Positioned(
    bottom: 12,
    right: 16,
    child: Row(
      children: List.generate(
        _banners.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 4),
          width: i == _cur ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == _cur ? AppColors.white : AppColors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    ),
  );
}

class _BannerData {
  final String title, subtitle;
  final Color colorStart, colorEnd;
  const _BannerData(this.title, this.subtitle, this.colorStart, this.colorEnd);
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.colorStart, data.colorEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bannerCircle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag(),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    color: AppColors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCtaButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'TERPOPULER',
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildCtaButton() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      'Pesan Sekarang',
      style: TextStyle(
        color: data.colorStart,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    ),
  );
}
