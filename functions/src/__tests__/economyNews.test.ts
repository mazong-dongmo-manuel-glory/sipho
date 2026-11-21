import {
  buildTakeaway,
  classifyTopic,
  googleNewsRssUrl,
  gnewsTopHeadlinesUrl,
  parseGoogleNewsRss,
  plainHeadline,
  topicEmoji,
} from "../shared/economyNews";

describe("economyNews", () => {
  test("builds Google News RSS URLs with country + query", () => {
    const fr = googleNewsRssUrl("FR");
    expect(fr).toContain("news.google.com/rss/search");
    expect(fr).toContain("gl=FR");
    expect(fr).toContain("ceid=FR%3Afr");
    expect(decodeURIComponent(fr)).toMatch(/inflation|pouvoir/);

    const cm = googleNewsRssUrl("CM");
    expect(cm).toContain("gl=CM");
    expect(decodeURIComponent(cm)).toMatch(/FCFA|Cameroun/);
  });

  test("gnews URL only for CA/FR/WORLD when key present", () => {
    expect(gnewsTopHeadlinesUrl("CM", "key")).toBeNull();
    expect(gnewsTopHeadlinesUrl("CA", "")).toBeNull();
    const url = gnewsTopHeadlinesUrl("CA", "abc");
    expect(url).toContain("gnews.io/api/v4/top-headlines");
    expect(url).toContain("country=ca");
    expect(url).toContain("category=business");
    expect(url).toContain("apikey=abc");
  });

  test("plainHeadline strips CDATA, HTML and publisher suffix", () => {
    expect(
      plainHeadline("<![CDATA[Inflation slows in France - Le Monde]]>")
    ).toBe("Inflation slows in France");
    expect(plainHeadline("Rent rises &amp; wages lag - CBC")).toBe(
      "Rent rises & wages lag"
    );
  });

  test("classifyTopic maps keywords", () => {
    expect(classifyTopic("Inflation hits groceries")).toBe("inflation");
    expect(classifyTopic("Mortgage rates jump")).toBe("housing");
    expect(classifyTopic("Banque centrale baisse le taux")).toBe("rates");
    expect(classifyTopic("Chômage en baisse")).toBe("jobs");
  });

  test("takeaway never invents numbers and stays educational", () => {
    const t = buildTakeaway("Foo", "inflation", "fr");
    expect(t).toMatch(/Sipho/);
    expect(t).not.toMatch(/\d+\s*%/);
    expect(topicEmoji("housing")).toBe("🏠");
  });

  test("parseGoogleNewsRss extracts items", () => {
    const xml = `<?xml version="1.0"?>
      <rss><channel>
        <item>
          <title>Inflation slows again - Radio-Canada</title>
          <link>https://example.com/a</link>
          <pubDate>Wed, 19 Nov 2026 10:00:00 GMT</pubDate>
          <source>Radio-Canada</source>
        </item>
        <item>
          <title>Housing costs rise in Montreal - CBC</title>
          <link>https://example.com/b</link>
          <pubDate>Wed, 19 Nov 2026 11:00:00 GMT</pubDate>
        </item>
      </channel></rss>`;
    const items = parseGoogleNewsRss(xml, "en");
    expect(items.length).toBe(2);
    expect(items[0].topic).toBe("inflation");
    expect(items[0].plainTitle).toContain("Inflation");
    expect(items[0].url).toContain("example.com/a");
    expect(items[1].topic).toBe("housing");
    expect(items[0].takeaway.length).toBeGreaterThan(20);
  });
});
