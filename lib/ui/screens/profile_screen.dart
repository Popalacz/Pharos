import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/orders_provider.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:pharos/ui/screens/order_tracking_screen.dart';
import 'package:pharos/ui/screens/localization_settings_screen.dart';
import 'package:pharos/ui/screens/login_screen.dart';
import 'package:pharos/data/models/user_model.dart';
import 'package:pharos/ui/screens/edit_profile_screen.dart';
import 'package:pharos/ui/screens/address_management_screen.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:pharos/ui/widgets/pharos_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.myProfile, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.text)),
        actions: [
          if (userProvider.isLoggedIn)
            IconButton(
              tooltip: AppLocalizations.of(context)!.a11yLogout,
              icon: const Icon(Icons.logout, color: AppColors.textSecondary),
              onPressed: () => userProvider.signOut(),
            )
        ],
      ),
      body: userProvider.isLoggedIn
          ? RefreshIndicator(
              onRefresh: () => context.read<OrdersProvider>().fetchOrders(),
              color: AppColors.accentText,
              backgroundColor: const Color(0xFF1A1A1A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(20),
                child: _LoggedInProfileContent(user: user!),
              ),
            )
          : _buildLoggedOutProfile(context),
    );
  }

  Widget _buildLoggedOutProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 100, color: AppColors.text.withOpacity(0.05)),
            const SizedBox(height: AppSpacing.s24),
            Text(
              AppLocalizations.of(context)!.profileHeading,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 1),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              AppLocalizations.of(context)!.profileGuestPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text.withOpacity(0.4), fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.s40),
            PharosButton(
              label: AppLocalizations.of(context)!.loginOrRegister,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedInProfileContent extends StatelessWidget {
  const _LoggedInProfileContent({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.text.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.accentText.withOpacity(0.1),
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person, color: AppColors.accentText, size: 35) : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(user.email, style: TextStyle(color: AppColors.text.withOpacity(0.4), fontSize: 14)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s40),
        Text(AppLocalizations.of(context)!.orderHistory, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.accentText, letterSpacing: 1.5)),
        const SizedBox(height: AppSpacing.s16),
        const _OrderHistorySection(),
        const SizedBox(height: AppSpacing.s40),
        Text(AppLocalizations.of(context)!.accountSettings, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.accentText, letterSpacing: 1.5)),
        const SizedBox(height: AppSpacing.s16),
        _ProfileMenuTile(
          icon: Icons.language_outlined,
          title: AppLocalizations.of(context)!.languageCurrency,
          subtitle: AppLocalizations.of(context)!.languageCurrencySubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizationSettingsScreen())),
        ),
        _ProfileMenuTile(
          icon: Icons.person_outline,
          title: AppLocalizations.of(context)!.myData,
          subtitle: AppLocalizations.of(context)!.myDataSubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
        ),
        _ProfileMenuTile(
          icon: Icons.location_on_outlined,
          title: AppLocalizations.of(context)!.myAddresses,
          subtitle: AppLocalizations.of(context)!.myAddressesSubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressManagementScreen())),
        ),
      ],
    );
  }
}

class _OrderHistorySection extends StatelessWidget {
  const _OrderHistorySection();

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

    if (ordersProvider.isLoading && ordersProvider.orders.isEmpty) {
      return const ListShimmer(itemCount: 2);
    }

    if (ordersProvider.errorMessage != null && ordersProvider.orders.isEmpty) {
      return _StatusCard(
        icon: Icons.error_outline,
        message: ordersProvider.errorMessage!,
        isError: true,
      );
    }

    if (ordersProvider.orders.isEmpty) {
      return _StatusCard(icon: Icons.receipt_long, message: AppLocalizations.of(context)!.noOrderHistory);
    }

    return Column(
      children: ordersProvider.orders.map((order) => _OrderTile(order: order)).toList(),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.accentText.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.accentText, size: 20),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.orderNumber(order.reference), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                      Text(order.date, style: TextStyle(color: AppColors.text.withOpacity(0.3), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${order.totalPaid.toStringAsFixed(2)} PLN', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
                    Text(order.status.toUpperCase(), style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isError ? AppColors.error.withOpacity(0.1) : AppColors.text.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: isError ? AppColors.error : AppColors.border, size: 32),
          const SizedBox(height: AppSpacing.s12),
          Text(message, style: TextStyle(color: isError ? AppColors.error : AppColors.textDisabled, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            leading: Icon(icon, color: AppColors.accentText, size: 24),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
            subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.text.withOpacity(0.4))),
            trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
