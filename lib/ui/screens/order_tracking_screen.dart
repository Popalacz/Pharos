import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';

import 'package:pharos/data/repositories/order_repository.dart';

import 'package:pharos/ui/screens/review_form_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderModel _currentOrder;
  bool _isRefreshing = false;
  late final IOrderRepository _orderRepository;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _orderRepository = OrderRepository(apiService: context.read<ApiService>());
  }

  Future<void> _refreshOrder() async {
    setState(() => _isRefreshing = true);
    final result = await _orderRepository.getOrderDetails(_currentOrder.id);
    
    result.fold(
      (failure) => debugPrint('Refresh Order Error: $failure'),
      (updatedOrder) {
        if (mounted) {
          setState(() {
            _currentOrder = updatedOrder;
          });
        }
      },
    );

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    
    // Definicja kroków na podstawie statusu z PrestaShop
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'ZAMÓWIENIE ZŁOŻONE',
        'desc': 'Otrzymaliśmy Twoje zamówienie i czekamy na weryfikację.',
        'icon': Icons.assignment_turned_in_outlined,
        'state': _getStepState(0, _currentOrder.status),
      },
      {
        'title': 'PŁATNOŚĆ ZAAKCEPTOWANA',
        'desc': 'Środki zostały zaksięgowane. Przekazujemy do realizacji.',
        'icon': Icons.account_balance_wallet_outlined,
        'state': _getStepState(1, _currentOrder.status),
      },
      {
        'title': 'W PRZYGOTOWANIU',
        'desc': 'Twoje produkty są właśnie pakowane i przygotowywane do wysyłki.',
        'icon': Icons.inventory_2_outlined,
        'state': _getStepState(2, _currentOrder.status),
      },
      {
        'title': 'WYSŁANO DO CIEBIE',
        'desc': 'Paczka opuściła nasz magazyn. Kurier jest już w drodze.',
        'icon': Icons.local_shipping_outlined,
        'state': _getStepState(3, _currentOrder.status),
      },
      {
        'title': 'DOSTARCZONO',
        'desc': 'Zamówienie dotarło! Dziękujemy za zakupy w Pharos.',
        'icon': Icons.verified_outlined,
        'state': _getStepState(4, _currentOrder.status),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ŚLEDZENIE ZAMÓWIENIA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _refreshOrder,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        color: Colors.orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderBrief(loc),
              const SizedBox(height: 40),
              const Text(
                'OŚ CZASU REALIZACJI',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white30),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return _OrderTimelineTile(
                    title: step['title'],
                    description: step['desc'],
                    icon: step['icon'],
                    state: step['state'],
                    isFirst: index == 0,
                    isLast: index == steps.length - 1,
                  );
                },
              ),
              const SizedBox(height: 40),
              if (_currentOrder.status == 'Dostarczono') ...[
                _buildReviewButton(),
                const SizedBox(height: 16),
              ],
              _buildSupportSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rate_rounded, color: Colors.green, size: 40),
          const SizedBox(height: 16),
          const Text('OCEŃ SWOJE ZAKUPY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text(
            'Twoja paczka została doręczona. Jak oceniasz produkty i obsługę?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => ReviewFormScreen(
                      orderId: _currentOrder.id,
                      title: 'Oceń zamówienie',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('DODAJ OPINIĘ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderBrief(LocalizationProvider loc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NUMER REFERENCYJNY', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(_currentOrder.reference, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentOrder.status.toUpperCase(),
                  style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _briefItem('DATA', _currentOrder.date.split(' ')[0]),
              _briefItem('METODA', _currentOrder.paymentMethod),
              _briefItem('WARTOŚĆ', loc.formatPrice(_currentOrder.totalPaid)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _briefItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded, color: Colors.orange, size: 40),
          const SizedBox(height: 16),
          const Text('POTRZEBUJESZ POMOCY?', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text(
            'Jeśli masz pytania dotyczące zamówienia, skontaktuj się z naszym opiekunem klienta.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ZADAJ PYTANIE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  _TimelineState _getStepState(int stepIdx, String currentStatus) {
    final statusMap = {
      'Oczekiwanie': 0,
      'Płatność zaakceptowana': 1,
      'W trakcie przygotowania': 2,
      'Wysłano': 3,
      'Dostarczono': 4,
    };

    final currentIdx = statusMap[currentStatus] ?? 0;

    if (stepIdx < currentIdx) return _TimelineState.completed;
    if (stepIdx == currentIdx) return _TimelineState.active;
    return _TimelineState.pending;
  }
}

enum _TimelineState { completed, active, pending }

class _OrderTimelineTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final _TimelineState state;
  final bool isFirst;
  final bool isLast;

  const _OrderTimelineTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.state,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = state == _TimelineState.completed 
        ? Colors.green 
        : (state == _TimelineState.active ? Colors.orange : Colors.white10);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: state == _TimelineState.active ? 2 : 1,
                  ),
                ),
                child: Icon(
                  state == _TimelineState.completed ? Icons.check : icon,
                  color: color,
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                    color: state == _TimelineState.pending ? Colors.white24 : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: state == _TimelineState.pending ? Colors.white10 : Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
