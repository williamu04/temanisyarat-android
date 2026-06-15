import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/translate/translate_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

// COLORS
class C {
  static const Color primary    = Color(0xFF0000CC);
  static const Color bg         = Color(0xFFFFFFFF);
  static const Color bgLight    = Color(0xFFF2F2F2);
  static const Color text       = Color(0xFF111111);
  static const Color textSub    = Color(0xFF555555);
  static const Color textMuted  = Color(0xFF888888);
  static const Color onPrimary  = Color(0xFFFFFFFF);
  static const Color divider    = Color(0xFFE0E0E0);
  static const Color navInactive= Color(0xFF888888);
  static const Color primaryLink= Color(0xFF0000CC);
}

// APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teman Isyarat',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: C.bgLight,
        colorScheme: ColorScheme.fromSeed(seedColor: C.primary, primary: C.primary),
      ),
      home: const MainPage(),
    );
  }
}

// ISYARAT DATA MODEL
class IsyaratItem {
  final int number;
  final String kode; 
  final String label;
  final Color placeholderColor;

  const IsyaratItem({
    required this.number,
    required this.kode,
    required this.label,
    required this.placeholderColor,
  });
}

const List<IsyaratItem> isyaratList = [
  IsyaratItem(number: 1,  kode: 'Saya',  label: 'Saya',  placeholderColor: Color(0xFF9E9E9E)),
  IsyaratItem(number: 2,  kode: 'Kamu',  label: 'Kamu',  placeholderColor: Color(0xFF9E9E9E)),
  IsyaratItem(number: 3,  kode: 'Teman', label: 'Teman', placeholderColor: Color(0xFF9E9E9E)),
  IsyaratItem(number: 4,  kode: 'Apel',  label: 'Apel',  placeholderColor: Color(0xFF9E9E9E)),
  IsyaratItem(number: 5,  kode: 'Besok', label: 'Besok', placeholderColor: Color(0xFF9E9E9E)),
  IsyaratItem(number: 6,  kode: 'Ayah',  label: 'Ayah',  placeholderColor: Color(0xFF9E9E9E)),
];

// ARTIKEL DATA MODEL
class Artikel {
  final String title;
  final String description;
  final String date;
  final String readTime;
  final String body;

  const Artikel({
    required this.title,
    required this.description,
    required this.date,
    required this.readTime,
    required this.body,
  });
}

const List<Artikel> artikelList = [
  Artikel(
    title: 'Profil Tim Pengembang',
    description: 'Tentang tim hibah berdampak Universitas Sebelas Maret #00000',
    date: 'Today',
    readTime: '3 min read',
    body:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
  ),
  Artikel(
    title: 'Tentang GERKATIN Surakarta',
    description: 'Gerakan untuk Kesejahteraan Tunarungu Indonesia',
    date: 'Today',
    readTime: '3 min read',
    body:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
  ),
  Artikel(
    title: 'Mengenal BISINDO Solo',
    description: 'Varian dari BISINDO yang dibentuk oleh komunitas tuli Surakarta',
    date: 'Today',
    readTime: '3 min read',
    body:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
  ),
  Artikel(
    title: 'Sejarah Bahasa Isyarat Indonesia',
    description: 'Perkembangan BISINDO dari masa ke masa sejak era 1980-an',
    date: 'Today',
    readTime: '5 min read',
    body:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
  ),
  Artikel(
    title: 'Cara Belajar BISINDO untuk Pemula',
    description: 'Panduan lengkap memulai belajar Bahasa Isyarat Indonesia',
    date: 'Today',
    readTime: '4 min read',
    body:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
  ),
];

// MAIN PAGE
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  void switchTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onSwitchTab: switchTab),
      const BelajarPage(),
      const ArtikelListPage(),
    ];

    return Scaffold(
      backgroundColor: C.bgLight,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _BottomNav(currentIndex: _index, onTap: switchTab),
    );
  }
}

// BOTTOM NAVIGATION
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.bg,
        border: Border(top: BorderSide(color: C.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _navItem(1, Icons.video_camera_front_outlined, Icons.video_camera_front, 'Belajar'),
              _navItem(2, Icons.article_outlined, Icons.article, 'Artikel'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData iconFilled, String label) {
    final sel = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: sel ? C.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  sel ? iconFilled : icon,
                  size: 22,
                  color: sel ? C.onPrimary : C.navInactive,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? C.text : C.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HOME PAGE
class HomePage extends StatelessWidget {
  final Function(int) onSwitchTab;

  const HomePage({super.key, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: C.bgLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 32, height: 32),
                  const SizedBox(width: 8),
                  const Text(
                    'Teman Isyarat',
                    style: TextStyle(
                      color: C.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsPage())),
                    child: const Icon(Icons.menu, color: C.text, size: 26),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _HeroCard(onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TranslatePage()),
                      );
                    }),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Artikel',
                            style: TextStyle(
                              color: C.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onSwitchTab(2),
                            child: const Icon(Icons.arrow_forward,
                                color: C.primary, size: 22),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 2, 16, 10),
                      child: Text(
                        'Klik untuk lihat lebih banyak.',
                        style: TextStyle(
                          fontSize: 14,
                          color: C.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                    ...artikelList.take(3).map((a) => _ArtikelItem(
                          artikel: a,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => DetailArtikelPage(artikel: a))),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 190,
        decoration: BoxDecoration(
          color: C.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: Image.asset(
                'assets/images/hand_camera.jpeg',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Terjemahkan',
                    style: TextStyle(
                      color: C.onPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: C.onPrimary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: C.onPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ARTIKEL ITEM 
class _ArtikelItem extends StatelessWidget {
  final Artikel artikel;
  final VoidCallback onTap;

  const _ArtikelItem({required this.artikel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/artikel_placeholder.jpeg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      artikel.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: C.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artikel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: C.textSub,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${artikel.date} • ${artikel.readTime}',
                      style: const TextStyle(
                        color: C.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TRANSLATE PAGE 
class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String _detected    = '';
  String _translation = '';
  bool   _isDetecting = false;

  void _simulateDetection() {
    setState(() {
      _isDetecting    = true;
      _detected       = '';
      _translation    = '';
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isDetecting    = false;
        _detected       = 'Teman';
        _translation    =
            'Isyarat ini berarti "Teman". Gerakan tangan menunjukkan dua jari yang saling bertautan sebagai simbol persahabatan.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1C1C1C),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: Colors.white.withOpacity(0.15), size: 80),
                    const SizedBox(height: 12),
                    Text(
                      'Preview Kamera',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.2), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Terjemahkan',
                    style: TextStyle(
                      color: C.onPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: C.onPrimary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: C.onPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: C.primary,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: C.onPrimary.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    if (_isDetecting) ...[
                      const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                              color: C.onPrimary, strokeWidth: 2.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text('Mendeteksi isyarat...',
                            style: TextStyle(
                                color: Color(0xCCFFFFFF), fontSize: 15)),
                      ),
                    ] else if (_detected.isNotEmpty) ...[
                      Text(
                        '$_detected...',
                        style: const TextStyle(
                          color: C.onPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _translation,
                        style: const TextStyle(
                          color: C.onPrimary,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                          height: 0.5,
                          color: C.onPrimary.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                        'sed do eiusmod tempor incididunt ut labore...',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Arahkan kamera ke tangan...',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tekan tombol di bawah untuk mulai mendeteksi gerakan isyarat.',
                        style: TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isDetecting ? null : _simulateDetection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.onPrimary,
                          foregroundColor: C.primary,
                          disabledBackgroundColor:
                              C.onPrimary.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text(
                          'Deteksi Isyarat',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BELAJAR PAGE 
class BelajarPage extends StatefulWidget {
  const BelajarPage({super.key});

  @override
  State<BelajarPage> createState() => _BelajarPageState();
}

class _BelajarPageState extends State<BelajarPage> {
  String _query = '';

  List<IsyaratItem> get filtered => isyaratList
      .where((e) =>
          e.label.toLowerCase().contains(_query.toLowerCase()) ||
          e.kode.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: C.bgLight,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: C.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.divider),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: C.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                            fontSize: 15, color: C.text),
                        decoration: const InputDecoration(
                          hintText: 'Cari kata',
                          hintStyle: TextStyle(
                              color: C.textMuted, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.search, color: C.textMuted, size: 18),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.78,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailIsyaratPage(isyarat: item),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBDBDBD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(Icons.sign_language,
                                  color: Color(0xFF757575), size: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Label bawah: #1 - Saya    Saya
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${item.number} - ${item.kode}',
                                style: const TextStyle(
                                  color: C.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                item.label,
                                style: const TextStyle(
                                  color: C.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DETAIL ISYARAT PAGE
class DetailIsyaratPage extends StatelessWidget {
  final IsyaratItem isyarat;

  const DetailIsyaratPage({super.key, required this.isyarat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back, color: C.text, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDBDBD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.sign_language,
                            color: Color(0xFF757575), size: 100),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isyarat.label,
                          style: const TextStyle(
                            color: C.text,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '#${isyarat.number} - ${isyarat.kode}',
                          style: const TextStyle(
                            color: C.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ARTIKEL LIST PAGE
class ArtikelListPage extends StatelessWidget {
  const ArtikelListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bgLight,
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: artikelList.length,
          itemBuilder: (_, i) => _ArtikelItem(
            artikel: artikelList[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailArtikelPage(artikel: artikelList[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// DETAIL ARTIKEL PAGE — sesuai Figma: judul besar, deskripsi,
class DetailArtikelPage extends StatelessWidget {
  final Artikel artikel;

  const DetailArtikelPage({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: C.text, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/artikel_placeholder.jpeg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      artikel.title,
                      style: const TextStyle(
                        color: C.text,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      artikel.description,
                      style: const TextStyle(
                        color: C.textSub,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      '${artikel.date} • ${artikel.readTime}',
                      style: const TextStyle(
                        color: C.primaryLink,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      artikel.body,
                      style: const TextStyle(
                        color: C.text,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Duis aute irure dolor in reprehenderit in voluptate velit '
                      'esse cillum dolore eu fugiat nulla pariatur. Excepteur sint '
                      'occaecat cupidatat non proident, sunt in culpa qui officia '
                      'deserunt mollit anim id est laborum.',
                      style: TextStyle(
                        color: C.text,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// SETTINGS PAGE
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
              color: C.text, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: C.bg,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: C.text, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        children: const [
          _SettingTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Kebijakan Privasi'),
          _SettingTile(
              icon: Icons.storage_outlined,
              label: 'Akses ke Dataset'),
          _SettingTile(
              icon: Icons.star_border,
              label: 'Beri Rating'),
          _SettingTile(
              icon: Icons.language,
              label: 'Website'),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: C.text, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          color: C.text,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {},
    );
  }
}
