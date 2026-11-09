import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class NewsItem {
  final String title;
  final String link;
  final String description;
  final String pubDate;

  NewsItem({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
  });

  factory NewsItem.fromXml(XmlElement element) {
    String getElementText(String name) {
      return element.findElements(name).isNotEmpty
          ? element.findElements(name).first.innerText.trim()
          : '';
    }

    String rawDesc = getElementText('description');
    String cleanDesc = rawDesc.replaceAll(RegExp(r'<[^>]*>'), '');

    return NewsItem(
      title: getElementText('title'),
      link: getElementText('link'),
      description: cleanDesc,
      pubDate: getElementText('pubDate'),
    );
  }
}

class NewsService {
  static const String rssUrl = 'https://apa.az/az/rss';

  static Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        return items.map((item) => NewsItem.fromXml(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
