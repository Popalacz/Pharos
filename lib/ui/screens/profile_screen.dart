import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:pharos/ui/screens/order_tracking_screen.dart';
import 'package:pharos/ui/screens/localization_settings_screen.dart';
import 'package:pharos/core/providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój Profil', style: TextStyle(fontWeight: FontWeight.bold)),
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
        : _buildLoggedOutProfile(context, userProvider),
    );
  }

  Widget _buildLoggedInProfile(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.05),
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<SettingsProvider>(
                    builder: (context, settings, child) => Text(
                      user.displayName ?? 'Użytkownik ${settings.settings.storeName}', 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                  ),
                  Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          
          const Text('Moje Zamówienia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          _buildOrderHistory(context),
          
          const SizedBox(height: 32),
          const Text('Ustawienia i Pomoc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          
          _buildMenuTile(context, Icons.language_outlined, 'Język i Waluta', 'Zmień ustawienia regionalne', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizationSettingsScreen()));
          }),
          _buildMenuTile(context, Icons.person_outline, 'Moje dane', 'Edytuj informacje o profilu', () {}),
          _buildMenuTile(context, Icons.location_on_outlined, 'Moje adresy', 'Zarządzaj adresami dostaw', () {}),
          _buildMenuTile(context, Icons.notifications_none_outlined, 'Powiadomienia', 'Ustawienia push', () {}),
        ],
      ),
    );
  }

  Widget _buildLoggedOutProfile(BuildContext context, UserProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 100, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 24),
            const Text('Zaloguj się, aby kontynuować', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Zyskaj dostęp do historii zamówień i szybkich płatności.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => provider.signIn(),
                icon: const Icon(Icons.login),
                label: const Text('ZALOGUJ PRZEZ GOOGLE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context) {
    final mockOrders = [
      OrderModel(id: 102, reference: 'PH-X921', date: '2024-03-10', totalPaid: 549.99, status: 'Wysłano', paymentMethod: 'Google Pay'),
      OrderModel(id: 105, reference: 'PH-A112', date: '2024-03-15', totalPaid: 129.00, status: 'Oczekiwanie', paymentMethod: 'BLIK'),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockOrders.length,
      itemBuilder: (context, index) {
        final order = mockOrders[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
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
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
