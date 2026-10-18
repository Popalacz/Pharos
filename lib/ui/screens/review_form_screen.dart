import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/core/utils/validation_feedback.dart';
import 'package:pharos/data/repositories/review_repository.dart';
import 'package:pharos/l10n/app_localizations.dart';

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
  final _formKey = GlobalKey<FormState>();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const Icon(Icons.rate_review_outlined, size: 80, color: AppColors.accentText),
            const SizedBox(height: AppSpacing.s24),
            Text(
              AppLocalizations.of(context)!.reviewHeading,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: AppSpacing.s8),
            const Text(
              'Podziel się swoimi wrażeniami z innymi klientami.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDisabled),
            ),
            const SizedBox(height: AppSpacing.s48),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  tooltip: AppLocalizations.of(context)!.a11yRateStars(index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 48,
                    color: index < _rating ? AppColors.accentText : AppColors.divider,
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
              style: const TextStyle(color: AppColors.accentText, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            
            const SizedBox(height: AppSpacing.s40),
            
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              validator: (value) => FormValidation.commentField(value),
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.reviewPlaceholder,
                hintStyle: const TextStyle(color: AppColors.divider),
                filled: true,
                fillColor: AppColors.text.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accentText),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.s48),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: AppColors.text)
                  : Text(AppLocalizations.of(context)!.submitReview, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
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
    if (!userProvider.isLoggedIn) {
      showValidationSnackBar(context, AppLocalizations.of(context)!.reviewLoginRequired);
      return;
    }

    final missingLabels = FormValidation.collectMissingLabels({
      AppLocalizations.of(context)!.reviewCommentLabel.toLowerCase(): FormValidation.commentField(_commentController.text),
    });
    if (missingLabels.isNotEmpty) {
      showValidationSnackBar(context, FormValidation.formatMissingFields(missingLabels));
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

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
          SnackBar(content: Text(AppLocalizations.of(context)!.reviewThanks), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.reviewSendError), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
