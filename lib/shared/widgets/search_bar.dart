import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MenuSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const MenuSearchBar({super.key, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),

          /// ICON SEARCH
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textGrey,
            size: 20,
          ),

          /// BUTTON CLEAR
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller!.clear();
                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                )
              : null,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}