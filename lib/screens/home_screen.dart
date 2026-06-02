import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../models/alamat_model.dart';
import '../services/alamat_service.dart';
import '../services/music_service.dart';
import '../widgets/alamat_card.dart';

// ── Hiwalay na widget para sa bawat category page ──
// Ginagamit ang AutomaticKeepAliveClientMixin para hindi ma-dispose
// ang page kahit lumayo — nananatili ang scroll position niya
class _CategoryPage extends StatefulWidget {
  final List<AlamatModel> stories;

  const _CategoryPage({super.key, required this.stories});

  @override
  State<_CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<_CategoryPage>
    with AutomaticKeepAliveClientMixin {

  // Sinasabi nito sa PageView na huwag i-dispose ang page
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // kailangan ito ng AutomaticKeepAliveClientMixin

    if (widget.stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: Colors.white.withOpacity(0.15)),
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
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.stories.length,
      itemBuilder: (ctx, i) => AlamatCard(
        alamat: widget.stories[i],
        language: 'fil',
      ),
    );
  }
}

// ────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AlamatService _service = AlamatService();
  final MusicService _music = MusicService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _filterScrollController = ScrollController();
  final PageController _pageController = PageController();

  List<AlamatModel> _all = [];
  String _activeFilter = 'lahat';
  String _searchQuery = '';
  bool _loading = true;

  static const Color _gold = Color(0xFFC9A84C);

  final List<Map<String, String>> _filters = [
    {'key': 'lahat',      'label': 'Lahat'},
    {'key': 'lalawigan',  'label': 'Lalawigan'},
    {'key': 'likas',      'label': 'Likas'},
    {'key': 'nilalang',   'label': 'Nilalang'},
    {'key': 'lunsod',     'label': 'Lunsod'},
    {'key': 'kasaysayan', 'label': 'Kasaysayan'},
    {'key': 'bayani',     'label': 'Bayani'},
    {'key': 'tribo',      'label': 'Tribo'},
    {'key': 'diyos',      'label': 'Diyos'},
    {'key': 'halaman',    'label': 'Halaman'},
    {'key': 'hayop',      'label': 'Hayop'},
    {'key': 'epiko',      'label': 'Epiko'},
  ];

  List<AlamatModel> _storiesFor(String key) {
    var result = _service.filterByCategory(_all, key);
    if (_searchQuery.isNotEmpty) {
      result = _service.search(result, _searchQuery);
    }
    result.sort((a, b) =>
        a.titleFil.toLowerCase().compareTo(b.titleFil.toLowerCase()));
    return result;
  }

  int get _activeCount => _storiesFor(_activeFilter).length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocus.dispose();
    _filterScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _music.pause();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      if (_music.isEnabled) _music.resume();
      if (mounted) setState(() {});
    }
  }

  Future<void> _load() async {
    final data = await _service.loadAll();
    if (mounted) {
      setState(() {
        _all = data;
        _loading = false;
      });
      if (!_music.isPlaying) {
        await _playMusicForFilter('lahat');
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _playMusicForFilter(String filterKey) async {
    final category = filterKey == 'lahat' ? '' : filterKey;
    final localPath = await _service.getLocalMusic(category);
    if (localPath != null) {
      await _music.playForCategory(category, localPath);
      if (mounted) setState(() {});
    }
  }

  void _selectFilter(int index) {
    final key = _filters[index]['key']!;
    setState(() => _activeFilter = key);
    _pageController.jumpToPage(index);
    _playMusicForFilter(key);
    _dismissKeyboard();
  }

  void _dismissKeyboard() => _searchFocus.unfocus();

  Future<void> _toggleMusic() async {
    await _music.toggle();
    if (mounted) setState(() {});
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
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC0F0E1A),
                      Color(0xAA0F0E1A),
                      Color(0xDD0F0E1A),
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            Column(
              children: [

                Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: statusBarHeight),

                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Image.asset(
                          'assets/images/alamat.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                      color: _gold.withOpacity(0.25)),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  onChanged: (v) {
                                    setState(() => _searchQuery = v);
                                  },
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) => _dismissKeyboard(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Hanapin ang kwento...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.30),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 10),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: _gold.withOpacity(0.75),
                                        size: 19,
                                      ),
                                    ),
                                    prefixIconConstraints:
                                        const BoxConstraints(
                                      minWidth: 0,
                                      minHeight: 0,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
                                              _dismissKeyboard();
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.10),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: Colors.white
                                                    .withOpacity(0.50),
                                                size: 15,
                                              ),
                                            ),
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 14,
                                    ),
                                  ),
                                  cursorColor: _gold,
                                  cursorWidth: 1.5,
                                  cursorRadius: const Radius.circular(2),
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                        child: SizedBox(
                          height: 34,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _filterScrollController,
                            itemCount: _filters.length,
                            itemBuilder: (ctx, i) {
                              final f = _filters[i];
                              final active = _activeFilter == f['key'];
                              return GestureDetector(
                                onTap: () => _selectFilter(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(right: 8),
                                  constraints:
                                      const BoxConstraints(minWidth: 64),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? _gold
                                        : Colors.black.withOpacity(0.30),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: active
                                          ? _gold
                                          : Colors.white.withOpacity(0.12),
                                    ),
                                    boxShadow: const [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      f['label']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: active
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: active
                                            ? const Color(0xFF0F0E1A)
                                            : Colors.white.withOpacity(0.6),
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

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _loading ? '' : '$_activeCount kwento',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.35),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ],
                  ),
                ),

                // ── PageView — bawat page ay _CategoryPage na may wantKeepAlive ──
                Expanded(
                  child: _loading
                      ? _buildShimmerGrid()
                      : PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filters.length,
                          itemBuilder: (ctx, i) => _CategoryPage(
                            key: PageStorageKey(_filters[i]['key']),
                            stories: _storiesFor(_filters[i]['key']!),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}