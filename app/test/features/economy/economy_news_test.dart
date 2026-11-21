import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/economy/domain/economy_news.dart';

void main() {
  test('EconomyNewsFeed.fromJson parses items and ignores junk', () {
    final feed = EconomyNewsFeed.fromJson({
      'countryCode': 'FR',
      'fetchedAt': '2026-11-20T07:15:00.000Z',
      'provider': 'google_news_rss',
      'items': [
        {
          'id': 'n_1',
          'title': 'Inflation en baisse',
          'takeaway': 'Revois ton enveloppe courses.',
          'topic': 'inflation',
          'emoji': '📉',
          'source': 'Le Monde',
          'url': 'https://example.com/a',
          'publishedAt': '2026-11-19T10:00:00.000Z',
        },
        'bad',
      ],
    });
    expect(feed.countryCode, 'FR');
    expect(feed.provider, 'google_news_rss');
    expect(feed.items, hasLength(1));
    expect(feed.items.first.topic, 'inflation');
    expect(feed.items.first.publishedAt, isNotNull);
  });

  test('empty feed helper', () {
    expect(EconomyNewsFeed.empty.isEmpty, isTrue);
  });
}
