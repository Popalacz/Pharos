import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    const String calendarUrl = "https://calendar.google.com/calendar/embed?src=6e67e8f88d83544199fb89c68454ba7c48aadf1f85e1fc86e0c56be537dc9670%40group.calendar.google.com&ctz=Europe%2FWarsaw";

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(calendarUrl));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.calendar.toUpperCase(), // "WYDARZENIA" w ARB
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _hasError
          ? _buildErrorState(context)
          : Stack(
              children: [
                if (_webViewController != null)
                  WebViewWidget(controller: _webViewController!),
                if (_isLoading) _buildLoadingState(),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Color.alphaBlend(AppColors.divider, AppColors.surface),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.text,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.calendarLoadError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeWebView();
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
