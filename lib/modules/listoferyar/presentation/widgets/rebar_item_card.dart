import 'package:flutter/material.dart';

import '../../domain/models/rebar_item.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';

class RebarItemCard extends StatelessWidget {
  const RebarItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final ListoferyarRebarItem item;
  final VoidCallback onDelete;

  String _number(double value) {
    return value
        .toStringAsFixed(3)
        .replaceFirst(
          RegExp(r'\.?0+$'),
          '',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: ListoferyarTheme.surfaceCard(
        radius: 17,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ListoferyarColors.surfaceBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.straighten_rounded,
                  color: ListoferyarColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'میلگرد Ø ${_number(item.diameter)} میلی‌متر',
                      style: ListoferyarTypography.cardTitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.quantity} شاخه',
                      style: ListoferyarTypography.helper,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: ListoferyarColors.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: ListoferyarColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Value(
                    title: 'تعداد',
                    value: '${item.quantity}',
                  ),
                ),
                Expanded(
                  child: _Value(
                    title: 'طول هر شاخه',
                    value: '${_number(item.length)} متر',
                  ),
                ),
                Expanded(
                  child: _Value(
                    title: 'فاصله میلگرد',
                    value: '${_number(item.spacing)} سانتی‌متر',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: ListoferyarColors.surfaceBlue.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Value(
                    title: 'وزن واحد',
                    value: '${_number(item.unitWeight)} kg/m',
                  ),
                ),
                Expanded(
                  child: _Value(
                    title: 'طول کل',
                    value: '${_number(item.totalLength)} متر',
                  ),
                ),
                Expanded(
                  child: _Value(
                    title: 'وزن کل',
                    value: '${_number(item.totalWeight)} کیلو',
                  ),
                ),
              ],
            ),
          ),

          if (item.description.trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: ListoferyarColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 19,
                    color: ListoferyarColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'توضیحات',
                          style: ListoferyarTypography.helper,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: ListoferyarTypography.bodyText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: ListoferyarTypography.helper,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ListoferyarTypography.bodyStrong,
        ),
      ],
    );
  }
}