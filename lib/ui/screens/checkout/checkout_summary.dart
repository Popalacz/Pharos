import 'package:flutter/material.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:pharos/l10n/app_localizations.dart';

class CheckoutVoucherSection extends StatelessWidget {
  const CheckoutVoucherSection({
    super.key,
    required this.controller,
    required this.isApplying,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool isApplying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
        border: Border.all(color: AppColors.text.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.voucherLabel.toUpperCase(), style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  onSubmitted: (_) => onApply(),
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.voucherHint,
                    hintStyle: TextStyle(color: AppColors.text.withOpacity(0.4)),
                    filled: true,
                    fillColor: AppColors.black.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              isApplying
                  ? const SizedBox(width: AppSpacing.s24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentText))
                  : ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                        foregroundColor: AppColors.accentText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.voucherUseButton, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckoutOrderSummary extends StatelessWidget {
  const CheckoutOrderSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.loc,
  });

  final double subtotal;
  final double shipping;
  final double total;
  final LocalizationProvider loc;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double calculatedTotal = subtotal + shipping;
    final double discount = (calculatedTotal - total).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
        border: Border.all(color: AppColors.text.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          _row(l10n.productsTotal, loc.formatPrice(subtotal)),
          const SizedBox(height: AppSpacing.s12),
          _row(l10n.shipping, shipping == 0 ? l10n.shippingFree : loc.formatPrice(shipping), color: shipping == 0 ? AppColors.success : null),
          if (discount > 0.05) ...[
            const SizedBox(height: AppSpacing.s12),
            _row(l10n.discount, '- ${loc.formatPrice(discount)}', color: AppColors.success),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppColors.divider)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 1.5)),
              Text(loc.formatPrice(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.accentText)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.text.withOpacity(0.6))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? AppColors.textSecondary)),
      ],
    );
  }
}
