import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/providers/orders_provider.dart';
import 'package:pharos/data/repositories/order_repository.dart';
import 'package:pharos/ui/screens/review_form_screen.dart';
import 'dart:async';

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

  Completer<GoogleMapController> _mapController = Completer();
  
  // Mock coordinates for demo (Warsaw Center to User Address)
  static const LatLng _warehouseLoc = LatLng(52.2297, 21.0122);
  static const LatLng _userLoc = LatLng(52.2356, 21.0101);
  static const LatLng _courierLoc = LatLng(52.2320, 21.0110);

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _orderRepository = OrderRepository(apiService: context.read<ApiService>());
    _initMapData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshOrder());
  }

  void _initMapData() {
    _markers = {
      Marker(
        markerId: const MarkerId('warehouse'),
        position: _warehouseLoc,
        infoWindow: const InfoWindow(title: 'Magazyn Pharos'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: _userLoc,
        infoWindow: const InfoWindow(title: 'Twój Adres'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      if (_currentOrder.status == 'Wysłano' || _currentOrder.status == 'W drodze')
        Marker(
          markerId: const MarkerId('courier'),
          position: _courierLoc,
          infoWindow: const InfoWindow(title: 'Kurier Pharos'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_warehouseLoc, _courierLoc, _userLoc],
        color: AppColors.accent,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
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
            _initMapData();
          });
          context.read<OrdersProvider>().fetchOrders();
        }
      },
    );

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'ZAMÓWIENIE ZŁOŻONE',
        'desc': 'Otrzymaliśmy Twoje zamówienie.',
        'icon': Icons.assignment_turned_in_outlined,
        'state': _getStepState(0, _currentOrder.status),
      },
      {
        'title': 'W PRZYGOTOWANIU',
        'desc': 'Twoje produkty są pakowane.',
        'icon': Icons.inventory_2_outlined,
        'state': _getStepState(1, _currentOrder.status),
      },
      {
        'title': 'W DRODZE',
        'desc': 'Kurier odebrał paczkę.',
        'icon': Icons.local_shipping_outlined,
        'state': _getStepState(2, _currentOrder.status),
      },
      {
        'title': 'DOSTARCZONO',
        'desc': 'Zamówienie dotarło!',
        'icon': Icons.verified_outlined,
        'state': _getStepState(3, _currentOrder.status),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('STATUS ZAMÓWIENIA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentText))
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _isRefreshing ? null : _refreshOrder,
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildMapHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshOrder,
                  color: AppColors.accentText,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(PharosLayout.spaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderBrief(loc),
                        const SizedBox(height: AppSpacing.s32),
                        _buildTimelineHeader(),
                        const SizedBox(height: AppSpacing.s24),
                        ...List.generate(steps.length, (index) {
                          final step = steps[index];
                          return _OrderTimelineTile(
                            title: step['title'],
                            description: step['desc'],
                            icon: step['icon'],
                            state: step['state'],
                            isFirst: index == 0,
                            isLast: index == steps.length - 1,
                          );
                        }),
                        const SizedBox(height: AppSpacing.s32),
                        if (_currentOrder.status == 'Dostarczono') ...[
                          _buildReviewButton(),
                          const SizedBox(height: AppSpacing.s16),
                        ],
                        _buildSupportSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: _courierLoc, zoom: 14),
        markers: _markers,
        polylines: _polylines,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
          controller.setMapStyle(_mapDarkStyle);
        },
      ),
    );
  }

  Widget _buildTimelineHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'HISTORIA REALIZACJI',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white24),
        ),
        Text(
          'DZIŚ, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.white10),
        ),
      ],
    );
  }

  Widget _buildOrderBrief(LocalizationProvider loc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('REFERENCJA', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: AppSpacing.s4),
                  Text(_currentOrder.reference, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentOrder.status.toUpperCase(),
                  style: const TextStyle(color: AppColors.accentText, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10, height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _briefItem('DATA', _currentOrder.date.split(' ')[0]),
              _briefItem('KWOTA', loc.formatPrice(_currentOrder.totalPaid)),
              _briefItem('STATUS', 'OPŁACONE'),
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
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.s4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildReviewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: Colors.green, size: 40),
          const SizedBox(height: AppSpacing.s12),
          const Text('JAK OCENIASZ PRODUKTY?', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)),
          const SizedBox(height: AppSpacing.s8),
          const Text(
            'Twoja opinia pomaga nam budować Pharos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewFormScreen(orderId: _currentOrder.id, title: 'Opinia')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('DODAJ OPINIĘ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded, color: AppColors.accentText, size: 32),
          const SizedBox(height: AppSpacing.s12),
          const Text('POMOC TECHNICZNA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentText,
                side: const BorderSide(color: AppColors.accent),
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
      'W przygotowaniu': 1,
      'Wysłano': 2,
      'Dostarczono': 3,
    };
    final currentIdx = statusMap[currentStatus] ?? 0;
    if (stepIdx < currentIdx) return _TimelineState.completed;
    if (stepIdx == currentIdx) return _TimelineState.active;
    return _TimelineState.pending;
  }

  static const String _mapDarkStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]
  ''';
}

enum _TimelineState { completed, active, pending }

class _OrderTimelineTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final _TimelineState state;
  final bool isFirst;
  final bool isLast;

  const _OrderTimelineTile({required this.title, required this.description, required this.icon, required this.state, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = state == _TimelineState.completed ? Colors.green : (state == _TimelineState.active ? AppColors.accent : Colors.white.withOpacity(0.05));
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: state == _TimelineState.active ? 2 : 1)),
                child: Icon(state == _TimelineState.completed ? Icons.check : icon, color: color, size: 18),
              ),
              if (!isLast) Expanded(child: Container(width: 1, color: color.withOpacity(0.2))),
            ],
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s4),
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: state == _TimelineState.pending ? Colors.white10 : Colors.white)),
                const SizedBox(height: AppSpacing.s4),
                Text(description, style: TextStyle(fontSize: 12, color: state == _TimelineState.pending ? Colors.white.withOpacity(0.02) : Colors.white54)),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
