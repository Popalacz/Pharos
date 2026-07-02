import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
    final settings = context.read<SettingsProvider>().settings;
    final embedUrl = settings.publicCalendarEmbedUrl;

    if (!settings.hasPublicCalendar || embedUrl == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

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
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = context.watch<LocalizationProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final title = settings.publicCalendarTitleFor(loc.currentLanguageCode);

    if (!settings.hasPublicCalendar) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(l10n.calendarUnavailable)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
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
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            const SizedBox(height: 16),
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
