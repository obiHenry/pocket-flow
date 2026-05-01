import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../exchange_rates/presentation/providers/exchange_rate_provider.dart';

class CurrencyTicker extends ConsumerStatefulWidget {
  const CurrencyTicker({super.key});

  @override
  ConsumerState<CurrencyTicker> createState() => _CurrencyTickerState();
}

class _CurrencyTickerState extends ConsumerState<CurrencyTicker>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;

  double _offset = 0;
  Duration? _lastElapsed;

  // pixels per second — increase to scroll faster
  static const double _speed = 50.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed!).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;

    _offset += _speed * dt;
    // Items are duplicated, so half-way is where the list repeats.
    // Resetting here is seamless — the content looks identical.
    final half = max / 2;
    if (_offset >= half) _offset -= half;

    _scrollController.jumpTo(_offset);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsync = ref.watch(exchangeRateProvider);

    return ratesAsync.maybeWhen(
      data: (rates) {
        final entries = rates.entries.toList();
        // Duplicate so the reset is invisible
        final doubled = [...entries, ...entries];

        return Container(
          height: 36,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: doubled.length,
            itemBuilder: (context, index) {
              final entry = doubled[index];
              return Container(
                margin: const EdgeInsets.only(right: 18),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₦${entry.value.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
