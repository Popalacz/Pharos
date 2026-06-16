import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:pharos/ui/screens/order_tracking_screen.dart';
import 'package:pharos/ui/screens/localization_settings_screen.dart';
import 'package:pharos/core/providers/settings_provider.dart';

import 'package:pharos/ui/screens/login_screen.dart';
import 'package:pharos/data/models/user_model.dart';

import 'package:pharos/ui/screens/edit_profile_screen.dart';
import 'package:pharos/ui/screens/address_management_screen.dart';

import 'package:pharos/data/repositories/order_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final IOrderRepository _orderRepository = OrderRepository();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MÓJ PROFIL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [
          if (userProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => userProvider.signOut(),
            )
        ],
      ),
      body: userProvider.isLoggedIn 
        ? _buildLoggedInProfile(context, user!)
        : _buildLoggedOutProfile(context),
    );
  }

  Widget _buildLoggedInProfile(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? const Icon(Icons.person, color: Colors.orange, size: 40) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const Text('HISTORIA ZAMÓWIEŃ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildOrderHistory(context, user.id),
          
          const SizedBox(height: 32),
          const Text('USTAWIENIA KONTA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          
          _buildMenuTile(context, Icons.language_outlined, 'Język i Waluta', 'Zmień ustawienia regionalne', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizationSettingsScreen()));
          }),
          _buildMenuTile(context, Icons.person_outline, 'Moje dane', 'Edytuj informacje o profilu', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          }),
          _buildMenuTile(context, Icons.location_on_outlined, 'Moje adresy', 'Zarządzaj adresami dostaw', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressManagementScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildLoggedOutProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 100, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),
            const Text('TWÓJ PROFIL PHAROS', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text('Zaloguj się, aby śledzić zamówienia i korzystać z szybkiego zakupu.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('ZALOGUJ LUB ZAŁÓŻ KONTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context, int customerId) {
    return FutureBuilder<List<OrderModel>>(
      future: _orderRepository.getCustomerOrders(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Colors.orange),
          ));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white24),
                SizedBox(width: 16),
                Text('Brak historii zamówień', style: TextStyle(color: Colors.white30)),
              ],
            ),
          );
        }

        final orders = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zamówienie #${order.reference}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(order.date, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${order.totalPaid.toStringAsFixed(2)} PLN', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.orange)),
                        Text(order.status, style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
          onTap: onTap,
        ),
      ),
    );
  }
}
