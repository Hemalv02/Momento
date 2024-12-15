import 'package:flutter/material.dart';
import 'package:momento/model/expense.dart';

class ChartBar extends StatelessWidget {
  const ChartBar({
    super.key,
    required this.fill,
    required this.category,
    required this.totalAmount,
  });

  final double fill;
  final Category category;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double multiplier = (isPortrait) ? 0.6 : 0.4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * multiplier,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.outline.withAlpha(76),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha(76),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: fill,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDarkMode
                            ? colorScheme.secondary
                            : colorScheme.primary.withAlpha(217),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '৳ ${totalAmount.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 4),
            Icon(
              categoryIcons[category],
              color: isDarkMode ? colorScheme.secondary : colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              category.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
