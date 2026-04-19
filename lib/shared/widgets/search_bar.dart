import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MenuSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const MenuSearchBar({
    super.key,
    this.onChanged,
    this.controller,
  });

  @override
  State<MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar> {
  @override
  void initState() {
    super.initState();

    widget.controller?.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller?.text ?? '';

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
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          hintStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),

          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textGrey,
            size: 20,
          ),

          suffixIcon: text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.controller?.clear();
                    widget.onChanged?.call('');
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