import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:pharos/ui/screens/order_tracking_screen.dart';
import 'package:pharos/ui/screens/localization_settings_screen.dart';
import 'package:pharos/ui/screens/login_screen.dart';
import 'package:pharos/data/models/user_model.dart';
import 'package:pharos/ui/screens/edit_profile_screen.dart';
import 'package:pharos/ui/screens/address_management_screen.dart';
import 'package:pharos/data/repositories/order_repository.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/core/error/failures.dart';

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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MÓJ PROFIL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        actions: [
          if (userProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? const Icon(Icons.person, color: Colors.orange, size: 35) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          const Text('HISTORIA ZAMÓWIEŃ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildOrderHistory(context, user.id),
          
          const SizedBox(height: 40),
          const Text('USTAWIENIA KONTA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1.5)),
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
            Text('Zaloguj się, aby śledzić zamówienia i korzystać z pełnej funkcjonalności aplikacji.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15, height: 1.5)),
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
                child: const Text('ZALOGUJ SIĘ LUB ZAŁÓŻ KONTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context, int customerId) {
    return FutureBuilder<Either<Failure, List<OrderModel>>>(
      future: _orderRepository.getCustomerOrders(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListShimmer(itemCount: 2);
        }

        if (snapshot.hasError || !snapshot.hasData) {
           return _buildStatusCard(Icons.error_outline, 'Nie udało się pobrać historii', isError: true);
        }

        return snapshot.data!.fold(
          (failure) => _buildStatusCard(Icons.error_outline, failure.message, isError: true),
          (orders) {
            if (orders.isEmpty) {
              return _buildStatusCard(Icons.receipt_long, 'Brak historii zamówień');
            }

            return Column(
              children: orders.map((order) => _buildOrderTile(context, order)).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderTile(BuildContext context, OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zamówienie #${order.reference}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(order.date, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${order.totalPaid.toStringAsFixed(2)} PLN', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(IconData icon, String message, {bool isError = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isError ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: isError ? Colors.red : Colors.white24, size: 32),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: isError ? Colors.red : Colors.white30, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Icon(icon, color: Colors.orange, size: 24),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
            trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
          ),
        ),
      ),
    );
  }
}
