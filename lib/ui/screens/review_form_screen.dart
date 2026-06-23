import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/repositories/review_repository.dart';

class ReviewFormScreen extends StatefulWidget {
  final int? productId;
  final int? orderId;
  final String title;

  const ReviewFormScreen({
    super.key, 
    this.productId, 
    this.orderId, 
    required this.title
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  late final IReviewRepository _reviewRepository;

  @override
  void initState() {
    super.initState();
    _reviewRepository = ReviewRepository(apiService: context.read<ApiService>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.rate_review_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'TWOJA OPINIA JEST DLA NAS WAŻNA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            const Text(
              'Podziel się swoimi wrażeniami z innymi klientami.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30),
            ),
            const SizedBox(height: 48),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 48,
                    color: index < _rating ? Colors.orange : Colors.white10,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _rating = index + 1.0);
                  },
                );
              }),
            ),
            Text(
              _getRatingLabel(),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            
            const SizedBox(height: 40),
            
            TextField(
              controller: _commentController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Napisz coś więcej...',
                hintStyle: const TextStyle(color: Colors.white10),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('WYŚLIJ OPINIĘ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel() {
    if (_rating >= 5) return 'REWELACJA!';
    if (_rating >= 4) return 'BARDZO DOBRZE';
    if (_rating >= 3) return 'MOŻE BYĆ';
    if (_rating >= 2) return 'SŁABO';
    return 'BARDZO SŁABO';
  }

  void _submitReview() async {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isLoggedIn) return;

    setState(() => _isSubmitting = true);

    bool isSuccess = false;
    if (widget.productId != null) {
      final result = await _reviewRepository.addProductReview(
        productId: widget.productId!,
        customerId: userProvider.user!.id,
        rating: _rating,
        comment: _commentController.text,
      );
      isSuccess = result.fold((l) => false, (r) => r);
    } else if (widget.orderId != null) {
      final result = await _reviewRepository.addOrderReview(
        orderId: widget.orderId!,
        customerId: userProvider.user!.id,
        rating: _rating,
        comment: _commentController.text,
      );
      isSuccess = result.fold((l) => false, (r) => r);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dziękujemy za Twoją opinię!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wystąpił błąd podczas wysyłania opinii.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
