import 'package:flutter/material.dart';
import 'package:pharos/data/models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Te statusy docelowo przychodzą z PrestaShop (history_states)
    final steps = [
      {'title': 'Zamówienie złożone', 'desc': 'Otrzymaliśmy Twoje zamówienie', 'done': true},
      {'title': 'Płatność zaakceptowana', 'desc': 'Środki zostały zaksięgowane', 'done': true},
      {'title': 'W trakcie przygotowania', 'desc': 'Pakujemy Twoje produkty', 'done': order.status != 'Oczekiwanie'},
      {'title': 'Wysłano', 'desc': 'Paczka jest już w drodze do Ciebie', 'done': order.status == 'Wysłano' || order.status == 'Dostarczono'},
      {'title': 'Dostarczono', 'desc': 'Ciesz się swoimi zakupami!', 'done': order.status == 'Dostarczono'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Zamówienie #${order.reference}', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status przesyłki', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ...steps.asMap().entries.map((entry) {
              int idx = entry.key;
              var step = entry.value;
              return _TrackingStep(
                title: step['title'] as String,
                desc: step['desc'] as String,
                isDone: step['done'] as bool,
                isLast: idx == steps.length - 1,
              );
            }),
            const SizedBox(height: 40),
            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.orange, size: 30),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Potrzebujesz pomocy?', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Nasz zespół jest do Twojej dyspozycji', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('CZAT', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String title;
  final String desc;
  final bool isDone;
  final bool isLast;

  const _TrackingStep({required this.title, required this.desc, required this.isDone, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? Colors.green : Colors.grey[300]!, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: isDone ? Colors.green : Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.black : Colors.grey)),
              Text(desc, style: TextStyle(fontSize: 12, color: isDone ? Colors.grey[600] : Colors.grey[400])),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}
