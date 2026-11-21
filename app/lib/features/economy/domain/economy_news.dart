class EconomyNewsItem {
  const EconomyNewsItem({
    required this.id,
    required this.title,
    required this.takeaway,
    required this.topic,
    required this.emoji,
    required this.source,
    required this.url,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String takeaway;
  final String topic;
  final String emoji;
  final String source;
  final String url;
  final DateTime? publishedAt;

  factory EconomyNewsItem.fromJson(Map<String, dynamic> json) {
    final published = json['publishedAt'];
    return EconomyNewsItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ??
          (json['plainTitle'] as String?) ??
          '',
      takeaway: (json['takeaway'] as String?) ?? '',
      topic: (json['topic'] as String?) ?? 'general',
      emoji: (json['emoji'] as String?) ?? '📰',
      source: (json['source'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      publishedAt: published is String ? DateTime.tryParse(published) : null,
    );
  }
}

class EconomyNewsFeed {
  const EconomyNewsFeed({
    required this.countryCode,
    required this.fetchedAt,
    required this.provider,
    required this.items,
  });

  final String countryCode;
  final DateTime? fetchedAt;
  final String provider;
  final List<EconomyNewsItem> items;

  bool get isEmpty => items.isEmpty;

  factory EconomyNewsFeed.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <EconomyNewsItem>[];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          items.add(EconomyNewsItem.fromJson(raw));
        } else if (raw is Map) {
          items.add(EconomyNewsItem.fromJson(Map<String, dynamic>.from(raw)));
        }
      }
    }
    final fetched = json['fetchedAt'];
    return EconomyNewsFeed(
      countryCode: (json['countryCode'] as String?) ?? '',
      fetchedAt: fetched is String ? DateTime.tryParse(fetched) : null,
      provider: (json['provider'] as String?) ?? 'none',
      items: items,
    );
  }

  static const empty = EconomyNewsFeed(
    countryCode: '',
    fetchedAt: null,
    provider: 'none',
    items: [],
  );
}
