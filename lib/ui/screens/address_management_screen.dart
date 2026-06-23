import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/ui/screens/address_form_screen.dart';

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
        title: const Text('MOJE ADRESY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: Stack(
        children: [
          userProvider.isLoadingAddresses && userProvider.addresses.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : Column(
                children: [
                  if (userProvider.isLoadingAddresses)
                    const LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.orange, minHeight: 2),
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
          
          // Senior Fix: Przycisk zakotwiczony w body zapobiega błędom NEEDS-LAYOUT
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 56,
              child: FloatingActionButton.extended(
                heroTag: 'management_add_address_safe',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressFormScreen())),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                label: const Text('DODAJ NOWY ADRES', style: TextStyle(fontWeight: FontWeight.bold)),
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
          Icon(Icons.location_off_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('Nie masz jeszcze zapisanych adresów', style: TextStyle(color: Colors.white30)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(address.alias.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white70),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddressFormScreen(address: address))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, address),
                  ),
                ],
              )
            ],
          ),
          Text('${address.firstname} ${address.lastname}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(address.address1, style: const TextStyle(color: Colors.white70)),
          Text('${address.postcode} ${address.city}', style: const TextStyle(color: Colors.white70)),
          if (address.phone != null) Text(address.phone!, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Usuń adres'),
        content: Text('Czy na pewno chcesz usunąć adres "${address.alias}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANULUJ')),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().deleteAddress(address.id);
              Navigator.pop(context);
            }, 
            child: const Text('USUŃ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
