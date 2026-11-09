import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const XeberlerApp());
}

class XeberlerApp extends StatelessWidget {
  const XeberlerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azərbaycan Xəbərləri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MainNewsScreen(),
    );
  }
}

class MainNewsScreen extends StatefulWidget {
  const MainNewsScreen({super.key});

  @override
  State<MainNewsScreen> createState() => _MainNewsScreenState();
}

class _MainNewsScreenState extends State<MainNewsScreen> {
  late Future<List<NewsItem>> _newsFuture;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  // Google Test Banner ID (Play Store-a buraxmazdan əvvəl öz AdMob ID-nizlə əvəz edin)
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService.fetchNews();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = NewsService.fetchNews();
    });
  }

  Future<void> _openNewsLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Xəbərlər', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNews,
          ),
        ],
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Xəbərlər yüklənmədi və ya internet bağlantısı yoxdur.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshNews,
                    child: const Text('Yenidən yoxla'),
                  ),
                ],
              ),
            );
          }

          final news = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshNews,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: news.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = news[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        item.pubDate,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                  onTap: () => _openNewsLink(item.link),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: _isBannerLoaded
          ? Container(
              color: Colors.white,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
