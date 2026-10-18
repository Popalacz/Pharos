import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:pharos/l10n/app_localizations.dart';

class CheckoutCarrierList extends StatelessWidget {
  const CheckoutCarrierList({
    super.key,
    required this.carriers,
    required this.hasError,
    required this.selected,
    required this.selectedShippingCost,
    required this.loc,
    required this.onSelect,
    required this.onRetry,
  });

  final List<CarrierModel>? carriers;
  final bool hasError;
  final CarrierModel? selected;
  final double selectedShippingCost;
  final LocalizationProvider loc;
  final ValueChanged<CarrierModel?> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = carriers;
    if (list == null) return const ListShimmer(itemCount: 2);
    if (hasError) return NetworkErrorState(message: l10n.carriersLoadFailed, onRetry: onRetry);
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      children: list.map((carrier) {
        final isSelected = selected?.id == carrier.id;
        return AnimatedContainer(
          duration: PharosLayout.motionFast,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _cardDecoration(isSelected),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
            child: RadioListTile<CarrierModel>(
              value: carrier,
              groupValue: selected,
              activeColor: AppColors.accentText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(carrier.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(carrier.delay, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    carrier.price == 0 ? l10n.shippingFree : loc.formatPrice(isSelected ? selectedShippingCost : carrier.price),
                    style: TextStyle(fontWeight: FontWeight.w900, color: carrier.price == 0 ? Colors.green : Colors.white, fontSize: 14),
                  ),
                ],
              ),
              secondary: carrier.imageUrl != null
                  ? Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: carrier.imageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => const Icon(Icons.local_shipping_rounded, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.local_shipping_rounded, color: Colors.white24, size: 28),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onSelect(val);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CheckoutPaymentList extends StatelessWidget {
  const CheckoutPaymentList({
    super.key,
    required this.payments,
    required this.hasError,
    required this.selected,
    required this.onSelect,
    required this.onRetry,
  });

  final List<PaymentMethodModel>? payments;
  final bool hasError;
  final PaymentMethodModel? selected;
  final ValueChanged<PaymentMethodModel> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = payments;
    if (list == null) return const ListShimmer(itemCount: 2);
    if (hasError) return NetworkErrorState(message: l10n.paymentsLoadFailed, onRetry: onRetry);
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      children: list.map((method) {
        final isSelected = selected?.id == method.id;
        final fallbackIcon = Icon(
          method.id.contains('blik') ? Icons.phonelink_ring_rounded : Icons.credit_card_rounded,
          color: isSelected ? AppColors.accentText : Colors.white24,
          size: 20,
        );
        return AnimatedContainer(
          duration: PharosLayout.motionFast,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _cardDecoration(isSelected),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
            child: ListTile(
              selected: isSelected,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: method.iconUrl != null
                    ? CachedNetworkImage(
                        imageUrl: method.iconUrl!,
                        width: 24,
                        height: 24,
                        errorWidget: (context, url, error) => fallbackIcon,
                      )
                    : fallbackIcon,
              ),
              title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(method.description ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.accentText, size: 22)
                  : Icon(Icons.circle_outlined, color: Colors.white.withOpacity(0.1), size: 22),
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(method);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

BoxDecoration _cardDecoration(bool isSelected) {
  return BoxDecoration(
    color: const Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
    border: Border.all(color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.05), width: isSelected ? 2 : 1),
    boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 12, spreadRadius: 2)] : null,
  );
}
