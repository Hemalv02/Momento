import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    required this.message,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}