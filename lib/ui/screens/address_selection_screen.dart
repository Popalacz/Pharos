import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/ui/screens/address_form_screen.dart';

class AddressSelectionScreen extends StatelessWidget {
  final AddressModel? selectedAddress;

  const AddressSelectionScreen({super.key, this.selectedAddress});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final addresses = userProvider.addresses;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Wybierz adres', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          userProvider.isLoadingAddresses && addresses.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : Column(
                children: [
                  if (userProvider.isLoadingAddresses)
                    const LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.orange, minHeight: 2),
                  Expanded(
                    child: addresses.isEmpty
                      ? const Center(child: Text('Nie masz jeszcze zapisanych adresów.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address = addresses[index];
                            final isSelected = selectedAddress?.id == address.id;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context, address);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: isSelected ? Colors.orange : Colors.white.withOpacity(0.05)),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(address.alias.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                                                  const Spacer(),
                                                  if (isSelected) const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text('${address.firstname} ${address.lastname}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                              Text(address.address1, style: TextStyle(color: Colors.white.withOpacity(0.6))),
                                              Text('${address.postcode} ${address.city}', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
          
          // Senior Fix: Przeniesienie przycisku FAB do Stacka body zapobiega błędowi "NEEDS-LAYOUT" w Scaffoldzie
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 56,
              child: FloatingActionButton.extended(
                heroTag: 'add_address_safe_tag',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddressFormScreen()),
                  ).then((result) {
                    if (result != null && result is AddressModel && context.mounted) {
                       Navigator.pop(context, result);
                    }
                  });
                },
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
}
