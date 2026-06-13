import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Wybierz adres', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: userProvider.isLoadingAddresses 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              final isSelected = selectedAddress?.id == address.id;
              
              return GestureDetector(
                onTap: () => Navigator.pop(context, address),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.orange : Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(address.alias, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                const Spacer(),
                                if (isSelected) const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${address.firstname} ${address.lastname}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.address1),
                            if (address.address2 != null) Text(address.address2!),
                            Text('${address.postcode} ${address.city}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressFormScreen()),
          );
          if (result != null && result is AddressModel) {
            // W prawdziwym systemie odświeżamy z API, tu dodajemy do listy mock
            userProvider.fetchAddresses(); 
          }
        },
        backgroundColor: Colors.black,
        label: const Text('DODAJ NOWY ADRES'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
