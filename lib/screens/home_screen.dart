import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../models/alamat_model.dart';
import '../services/alamat_service.dart';
import '../widgets/alamat_card.dart';
import 'episode_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlamatService _service = AlamatService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<AlamatModel> _all = [];
  List<AlamatModel> _filtered = [];
  String _activeFilter = 'lahat';
  String _searchQuery = '';
  bool _loading = true;

  final List<Map<String, dynamic>> _filters = [
    {'key': 'lahat',    'label': 'Lahat'},
    {'key': 'likas',    'label': 'Likas'},
    {'key': 'bayani',   'label': 'Bayani'},
    {'key': 'nilalang', 'label': 'Nilalang'},
    {'key': 'diyos',    'label': 'Diyos'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _service.loadAll();
    if (mounted) {
      setState(() {
        _all = data;
        _filtered = data;
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    var result = _service.filterByRegion(_all, _activeFilter);
    result = _service.search(result, _searchQuery);
    setState(() => _filtered = result);
  }

  // ── Dismiss keyboard when tapping outside search ──
  void _dismissKeyboard() {
    _searchFocus.unfocus();
  }

  void _navigate(Widget screen) {
    // Always dismiss keyboard before navigating
    _dismissKeyboard();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 220),
        barrierColor: const Color(0xFF0F0E1A),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 8,
      itemBuilder: (ctx, i) => Shimmer.fromColors(
        baseColor: const Color(0xFF1B1A2E),
        highlightColor: const Color(0xFF2A2940),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1A2E),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      // Tap anywhere outside search bar → dismiss keyboard
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E1A),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            // ── Header ──
            Container(
              color: const Color(0xFF0F0E1A),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: statusBarHeight),

                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.asset(
                      'assets/images/alamat.png',
                      height: 86,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF151424),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFC9A84C).withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: (v) {
                          _searchQuery = v;
                          _applyFilters();
                        },
                        // Dismiss keyboard on "search/done" action
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _dismissKeyboard(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Hanapin ang kwento...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFFC9A84C).withOpacity(0.6),
                            size: 20,
                          ),
                          // Clear button — shown only when there's text
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _applyFilters();
                                    _dismissKeyboard();
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          // Remove the default underline/cursor line
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        // Remove cursor line color bleed
                        cursorColor: const Color(0xFFC9A84C),
                        cursorWidth: 1.5,
                      ),
                    ),
                  ),

                  // Filter pills
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                    child: SizedBox(
                      height: 34,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (ctx, i) {
                          final f = _filters[i];
                          final active = _activeFilter == f['key'];
                          return GestureDetector(
                            onTap: () {
                              _dismissKeyboard();
                              _activeFilter = f['key'];
                              _applyFilters();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 8),
                              // Fixed width so text is always centered
                              constraints: const BoxConstraints(minWidth: 64),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFFC9A84C)
                                    : const Color(0xFF151424),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? const Color(0xFFC9A84C)
                                      : Colors.white.withOpacity(0.08),
                                ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFC9A84C)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              // Center the label inside the pill
                              child: Center(
                                child: Text(
                                  f['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: active
                                        ? const Color(0xFF0F0E1A)
                                        : Colors.white.withOpacity(0.5),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Count
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _loading
                            ? ''
                            : '${_filtered.length} kwento',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ],
              ),
            ),

            // ── Grid ──
            Expanded(
              child: _loading
                  ? _buildShimmerGrid()
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Colors.white.withOpacity(0.15),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Walang nakitang kwento',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => AlamatCard(
                            alamat: _filtered[i],
                            language: 'fil',
                            onTap: () => _navigate(EpisodeListScreen(
                              alamat: _filtered[i],
                              language: 'fil',
                            )),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}