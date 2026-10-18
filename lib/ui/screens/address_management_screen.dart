import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/ui/screens/address_form_screen.dart';
import 'package:pharos/l10n/app_localizations.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myAddressesTitle, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: Stack(
        children: [
          userProvider.isLoadingAddresses && userProvider.addresses.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentText))
            : Column(
                children: [
                  if (userProvider.isLoadingAddresses)
                    const LinearProgressIndicator(backgroundColor: Colors.transparent, color: AppColors.accentText, minHeight: 2),
                  Expanded(
                    child: userProvider.addresses.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                          itemCount: userProvider.addresses.length,
                          itemBuilder: (context, index) {
                            final address = userProvider.addresses[index];
                            return _buildAddressCard(context, address);
                          },
                        ),
                  ),
                ],
              ),
          
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 56,
              child: FloatingActionButton.extended(
                heroTag: 'management_add_address_safe',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressFormScreen())),
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.text,
                label: Text(AppLocalizations.of(context)!.addNewAddressButton, style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: AppColors.text.withOpacity(0.05)),
          const SizedBox(height: AppSpacing.s16),
          Text(AppLocalizations.of(context)!.noSavedAddresses, style: TextStyle(color: AppColors.textDisabled)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.text.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(address.alias.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentText, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.a11yEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddressFormScreen(address: address))),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.a11yRemove,
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                    onPressed: () => _confirmDelete(context, address),
                  ),
                ],
              )
            ],
          ),
          Text('${address.firstname} ${address.lastname}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: AppSpacing.s4),
          Text(address.address1, style: const TextStyle(color: AppColors.textSecondary)),
          Text('${address.postcode} ${address.city}', style: const TextStyle(color: AppColors.textSecondary)),
          if (address.phone != null) Text(address.phone!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(AppLocalizations.of(context)!.deleteAddress),
        content: Text(AppLocalizations.of(context)!.deleteAddressConfirm(address.alias)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancelButton)),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().deleteAddress(address.id);
              Navigator.pop(context);
            }, 
            child: Text(AppLocalizations.of(context)!.deleteButton, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
