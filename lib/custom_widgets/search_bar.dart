import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClose;
  final bool isSearchMode;

  const SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClose,
    required this.isSearchMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isSearchMode
        ? TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search events...',
              hintStyle: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 18.sp, color: Colors.black),
          )
        : Text(
            'Momento',
            style: TextStyle(fontFamily: "Lalezar", fontSize: 36.sp),
          );
  }
}