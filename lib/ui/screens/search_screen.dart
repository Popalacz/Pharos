import 'package:pharos/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/ui/widgets/search_filter_drawer.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:pharos/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      AppLog.e('Speech init error: $e');
    }
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() => _isListening = true);
      _showVoiceSearchOverlay();
      
      await _speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            _controller.text = val.recognizedWords;
            context.read<SearchProvider>().onQueryChanged(val.recognizedWords);
            context.read<SearchProvider>().performFullSearch();
            _stopListening();
          }
        },
        localeId: context.read<LocalizationProvider>().currentLanguage?.isoCode ?? 'pl_PL',
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    if (mounted && _isListening) {
      setState(() => _isListening = false);
      Navigator.of(context).pop(); // Close overlay
    }
  }

  void _showVoiceSearchOverlay() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const Spacer(),
            Text(AppLocalizations.of(context)!.listening, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
            const SizedBox(height: AppSpacing.s24),
            Stack(
              alignment: Alignment.center,
              children: [
                Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_6p8ov8.json',
                  height: 120,
                  repeat: true,
                ),
                const Icon(Icons.mic, color: Colors.orange, size: 40),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: _stopListening,
              child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) {
      if (_isListening) _stopListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const SearchFilterDrawer(),
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.a11yBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => context.read<SearchProvider>().onQueryChanged(val),
          onSubmitted: (_) => context.read<SearchProvider>().performFullSearch(),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchInStore(settings.storeName),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: false,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.a11yVoiceSearch,
            icon: const Icon(Icons.mic_none_rounded, color: Colors.orange),
            onPressed: _startListening,
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.a11yFilters,
            icon: const Icon(Icons.tune),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: AppLocalizations.of(context)!.a11yClose,
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                context.read<SearchProvider>().clearSearch();
              },
            ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.isSearching) {
            return const ProductShimmer();
          }

          if (searchProvider.query.isEmpty) {
            if (searchProvider.recentSearches.isNotEmpty) {
              return _buildRecentSearches(searchProvider);
            }
            return _buildEmptyState('Zacznij pisać, aby znaleźć produkty', icon: Icons.search_rounded);
          }

          // Show Autocomplete suggestions if full results are not yet loaded
          if (searchProvider.searchResults.isEmpty && (searchProvider.isSuggesting || searchProvider.suggestions.isNotEmpty)) {
            return _buildSuggestions(searchProvider);
          }

          if (searchProvider.searchResults.isEmpty && !searchProvider.isSuggesting) {
            return _buildEmptyState('Nie znaleźliśmy produktów pasujących do "${searchProvider.query}"');
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final product = searchProvider.searchResults[index];
              return PharosProductCard(product: product, heroTagPrefix: 'search');
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches(SearchProvider searchProvider) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recentSearches,
                style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
              ),
              TextButton(
                onPressed: () => searchProvider.clearRecentSearches(),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: Text(AppLocalizations.of(context)!.clearLabel, style: TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            ],
          ),
        ),
        ...searchProvider.recentSearches.map((query) => ListTile(
          leading: const Icon(Icons.history, color: Colors.white24, size: 20),
          title: Text(query, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          trailing: IconButton(
            tooltip: AppLocalizations.of(context)!.a11yClose,
            icon: const Icon(Icons.close, size: 16, color: Colors.white24),
            onPressed: () => searchProvider.removeRecentSearch(query),
          ),
          onTap: () {
            _controller.text = query;
            searchProvider.onQueryChanged(query);
            searchProvider.performFullSearch();
          },
        )),
      ],
    );
  }

  Widget _buildSuggestions(SearchProvider searchProvider) {
    return ListView(
      children: [
        if (searchProvider.isSuggesting)
          const LinearProgressIndicator(minHeight: 2, color: Colors.orange, backgroundColor: Colors.transparent),
        
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(AppLocalizations.of(context)!.suggestions, style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
        ),
        
        ...searchProvider.suggestions.map((product) => ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white10),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover),
          ),
          title: Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text(product.manufacturerName, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: const Icon(Icons.north_west, size: 16, color: Colors.white24),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
          },
        )),
        
        if (searchProvider.query.length >= 3)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              onPressed: () => searchProvider.performFullSearch(),
              icon: const Icon(Icons.search, size: 18),
              label: Text(AppLocalizations.of(context)!.searchFor(searchProvider.query), style: const TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: Colors.orange, alignment: Alignment.centerLeft),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message, {IconData icon = Icons.search_off}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets9.lottiefiles.com/private_files/lf30_cg9qtpre.json',
              height: 180,
              repeat: true,
              errorBuilder: (context, error, stackTrace) => Icon(icon, size: 80, color: Colors.white.withOpacity(0.05)),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              message.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
