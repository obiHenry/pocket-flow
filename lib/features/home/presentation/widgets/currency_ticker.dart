import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../exchange_rates/presentation/providers/exchange_rate_provider.dart';

class CurrencyTicker extends ConsumerWidget {
  const CurrencyTicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(exchangeRateProvider);

    return ratesAsync.maybeWhen(
      // error: (error, stackTrace) => ,
      data: (rates) => Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: rates.length,
          itemBuilder: (context, index) {
            final key = rates.keys.elementAt(index);
            final value = rates.values.elementAt(index);
            return Container(
              margin: const EdgeInsets.only(right: 24),
              child: Row(
                children: [
                  Text(
                    key,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value.toStringAsFixed(2),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      orElse: () => const SizedBox.shrink(), // Don't show if loading/error
    );
  }
}
