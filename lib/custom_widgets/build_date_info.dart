
import 'package:flutter/material.dart';

Widget buildDateInfo(
    BuildContext context,
    IconData icon,
    String label,
    String date,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        // const SizedBox(height: 4),
        Text(
          date,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }