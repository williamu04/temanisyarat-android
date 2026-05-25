import 'package:flutter/material.dart';
import 'pages/translate/translate_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teman Isyarat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  void _navigateToTranslate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TranslatePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigateTranslate: () => _navigateToTranslate(context)),
      const PlaceholderPage(label: 'Belajar'),
      const ArtikelPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: CustomNavigationBarWrapper(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String label;

  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

class CustomNavigationBarWrapper extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBarWrapper({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SafeArea(
        top: false,
        child: CustomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Teman Isyarat',
            style: TextStyle(
              color: Color(0xFF09096F),
              fontSize: 22.53,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 0.91,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            child: const Icon(Icons.menu, color: Colors.black, size: 28),
          ),
        ],
      ),
    );
  }
}

class Section2 extends StatelessWidget {
  final VoidCallback onNavigate;

  const Section2({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onNavigate,
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mulai Terjemahkan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tekan untuk membuka kamera dan menerjemahkan isyarat tangan secara real-time',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Color(0xFF2196F3), size: 28),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Section5 extends StatelessWidget {
  const Section5({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const SectionHeader(text: 'Artikel'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Klik untuk lihat lebih banyak.',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.25,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: const [
                ListItemWidget(
                  title: 'Profil Tim Pengembang',
                  description:
                      'Tentang tim hibah berdampak Universitas Sebelas Maret #00000',
                  date: 'Today',
                  readTime: '3 min read',
                ),
                ListItemWidget(
                  title: 'Tentang GERKATIN Surakarta',
                  description:
                      'Gerakan untuk Kesejahteraan Tunarungu Indonesia',
                  date: 'Today',
                  readTime: '3 min read',
                ),
                ListItemWidget(
                  title: 'Mengenal BISINDO Solo',
                  description:
                      'Varian dari BISINDO yang dibentuk oleh komunitas tuli Surak...',
                  date: 'Today',
                  readTime: '3 min read',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF09096F),
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String readTime;

  const ListItemWidget({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF0000CC),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    letterSpacing: 0.25,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(color: Color(0xFF111111), fontSize: 12),
                    ),
                    Text(
                      readTime,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(0, Icons.home, 'Home'),
          _buildNavItem(1, Icons.camera, 'Belajar'),
          _buildNavItem(2, Icons.article, 'Artikel'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onNavigateTranslate;

  const HomePage({super.key, required this.onNavigateTranslate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(),
            Section2(onNavigate: onNavigateTranslate),
            const Section5(),
          ],
        ),
      ),
    );
  }
}

class ArtikelPage extends StatelessWidget {
  const ArtikelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artikel")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, i) => ListTile(
          leading: const SizedBox(
            width: 50,
            height: 50,
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.blue)),
          ),
          title: Text("Headline ${i + 1}"),
          subtitle: const Text("Today • 3 min read"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DetailArtikel()),
            );
          },
        ),
      ),
    );
  }
}

class DetailArtikel extends StatelessWidget {
  const DetailArtikel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artikel")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 200, color: Colors.blue),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Headline",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Isi artikel panjang lorem ipsum..."),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Kebijakan Privasi"),
          ),
          ListTile(
            leading: Icon(Icons.data_usage),
            title: Text("Akses Dataset"),
          ),
          ListTile(leading: Icon(Icons.star), title: Text("Beri Rating")),
          ListTile(leading: Icon(Icons.web), title: Text("Website")),
        ],
      ),
    );
  }
}
