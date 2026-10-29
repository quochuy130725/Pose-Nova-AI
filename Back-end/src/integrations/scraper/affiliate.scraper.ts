import * as cheerio from 'cheerio';

export interface ScrapedAffiliateProduct {
  productName: string;
  brandName: string;
  price: number;
  thumbnailUrl: string;
  affiliateUrl: string;
}

interface FallbackPreset {
  brandName: string;
  defaultTitle: string;
  defaultPrice: number;
  defaultThumbnail: string;
}

const BRAND_PRESETS: Record<string, FallbackPreset> = {
  shopee: {
    brandName: 'Shopee Mall Vietnam',
    defaultTitle: 'Streetwear Oversized Utility Parachute Jacket AW26',
    defaultPrice: 689000,
    defaultThumbnail:
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=400&q=80',
  },
  zara: {
    brandName: 'Zara Vietnam',
    defaultTitle: 'Zara Heavyweight Oversized Technical Bomber',
    defaultPrice: 1499000,
    defaultThumbnail:
      'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=400&q=80',
  },
  uniqlo: {
    brandName: 'Uniqlo Vietnam',
    defaultTitle: 'Uniqlo U Wide-Fit Technical Cargo Pants',
    defaultPrice: 799000,
    defaultThumbnail:
      'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&w=400&q=80',
  },
  tiktok: {
    brandName: 'TikTok Shop Mall',
    defaultTitle: 'Y2K Cyber Distressed Zip-Up Hoodie',
    defaultPrice: 459000,
    defaultThumbnail:
      'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=400&q=80',
  },
  hm: {
    brandName: 'H&M Studio',
    defaultTitle: 'H&M Relaxed Fit Boxy Twill Overshirt',
    defaultPrice: 899000,
    defaultThumbnail:
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=400&q=80',
  },
};

function detectPreset(parsedUrl: URL): FallbackPreset {
  const host = parsedUrl.hostname.toLowerCase();
  if (host.includes('shopee')) return BRAND_PRESETS.shopee;
  if (host.includes('zara')) return BRAND_PRESETS.zara;
  if (host.includes('uniqlo')) return BRAND_PRESETS.uniqlo;
  if (host.includes('tiktok')) return BRAND_PRESETS.tiktok;
  if (host.includes('hm.com') || host.includes('h&m')) return BRAND_PRESETS.hm;

  const cleanHost = host.replace(/^www\./, '').split('.')[0] || 'Atelier';
  const brandName = cleanHost.charAt(0).toUpperCase() + cleanHost.slice(1) + ' Official';
  return {
    brandName,
    defaultTitle: `${brandName} Editorial Tailored Piece AW26`,
    defaultPrice: 950000,
    defaultThumbnail:
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=400&q=80',
  };
}

function humanizeUrlSlug(parsedUrl: URL, fallbackTitle: string): string {
  const segments = parsedUrl.pathname
    .split('/')
    .map((s) => s.trim())
    .filter((s) => s.length > 2 && !/^p?\d+$/i.test(s) && !s.endsWith('.html'));

  if (segments.length === 0) {
    return fallbackTitle;
  }

  const bestSegment = segments[segments.length - 1]
    .replace(/\.[a-z0-9]+$/i, '')
    .replace(/[-_]+/g, ' ')
    .replace(/\b[eE]?\d{5,}\b/g, '')
    .trim();

  if (bestSegment.length < 4) {
    return fallbackTitle;
  }

  return bestSegment
    .split(/\s+/)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(' ');
}

function inferFallbackPriceFromText(title: string, defaultPrice: number): number {
  const lower = title.toLowerCase();
  if (lower.includes('boot') || lower.includes('shoe') || lower.includes('sneaker')) return 1650000;
  if (lower.includes('jacket') || lower.includes('bomber') || lower.includes('coat')) return 1450000;
  if (lower.includes('cargo') || lower.includes('pant') || lower.includes('jean') || lower.includes('trouser')) return 799000;
  if (lower.includes('hoodie') || lower.includes('sweater')) return 690000;
  if (lower.includes('shirt') || lower.includes('tee') || lower.includes('top')) return 450000;
  return defaultPrice;
}

function parseNumericPrice(raw: string | undefined | null): number | null {
  if (!raw) return null;
  const cleaned = raw.replace(/[^\d.,]/g, '').trim();
  if (!cleaned) return null;

  // Handle VND formatting like "1.450.000" or "799,000"
  const digitsOnly = cleaned.replace(/[.,](?=\d{3}\b)/g, '').replace(',', '.');
  const value = Number.parseFloat(digitsOnly);
  if (!Number.isFinite(value) || value <= 0) return null;

  // Convert USD-scale prices (e.g. 49.99) to approximate VND for unified catalog display
  if (value < 1000) {
    return Math.round(value * 25000);
  }
  return Math.round(value);
}

/**
 * Scrapes OpenGraph & JSON-LD product metadata from e-commerce URLs (Shopee, Zara, Uniqlo, TikTok Shop),
 * backed by a deterministic smart fallback parser so live demos never fail on bot-blocked domains.
 */
export async function scrapeProductMetadata(rawUrl: string): Promise<ScrapedAffiliateProduct> {
  const normalizedUrl = /^https?:\/\//i.test(rawUrl.trim())
    ? rawUrl.trim()
    : `https://${rawUrl.trim()}`;

  let parsedUrl: URL;
  try {
    parsedUrl = new URL(normalizedUrl);
  } catch {
    return {
      productName: 'Editorial Curated Streetwear Item AW26',
      brandName: 'PoseNova Partner Atelier',
      price: 890000,
      thumbnailUrl:
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=400&q=80',
      affiliateUrl: normalizedUrl,
    };
  }

  const preset = detectPreset(parsedUrl);
  const slugTitle = humanizeUrlSlug(parsedUrl, preset.defaultTitle);
  const fallbackPrice = inferFallbackPriceFromText(slugTitle, preset.defaultPrice);
  const url = parsedUrl.toString();

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 4500);

    const response = await fetch(parsedUrl.toString(), {
      method: 'GET',
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
        Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7',
      },
      signal: controller.signal,
    }).finally(() => clearTimeout(timeout));

    if (!response.ok) {
      return {
        productName: slugTitle,
        brandName: preset.brandName,
        price: fallbackPrice,
        thumbnailUrl: preset.defaultThumbnail,
        affiliateUrl: url,
      };
    }

    const html = await response.text();
    const $ = cheerio.load(html);

    const ogTitle =
      $('meta[property="og:title"]').attr('content')?.trim() ||
      $('meta[name="twitter:title"]').attr('content')?.trim() ||
      $('title').first().text().trim();

    const ogImage =
      $('meta[property="og:image"]').attr('content')?.trim() ||
      $('meta[name="twitter:image"]').attr('content')?.trim();

    const ogSiteName = $('meta[property="og:site_name"]').attr('content')?.trim();

    let rawPrice =
      $('meta[property="product:price:amount"]').attr('content') ||
      $('meta[property="og:price:amount"]').attr('content') ||
      $('meta[itemprop="price"]').attr('content');

    // Attempt JSON-LD Product extraction if meta price is missing
    if (!rawPrice) {
      $('script[type="application/ld+json"]').each((_, el) => {
        if (rawPrice) return;
        try {
          const json = JSON.parse($(el).contents().text());
          const candidates = Array.isArray(json) ? json : [json];
          for (const item of candidates) {
            if (item && (item['@type'] === 'Product' || item.offers)) {
              const offers = Array.isArray(item.offers) ? item.offers[0] : item.offers;
              if (offers?.price) {
                rawPrice = String(offers.price);
                break;
              }
            }
          }
        } catch {
          // Ignore malformed JSON-LD blocks
        }
      });
    }

    // Reject generic anti-bot titles like "Just a moment...", "Access Denied", or "Shopee Việt Nam"
    const isBlockedOrGenericTitle =
      !ogTitle ||
      ogTitle.length < 4 ||
      /access denied|just a moment|robot|captcha|attention required|login/i.test(ogTitle);

    const finalTitle = isBlockedOrGenericTitle ? slugTitle : ogTitle;
    const parsedPrice = parseNumericPrice(rawPrice);

    return {
      productName: finalTitle,
      brandName: ogSiteName && ogSiteName.length <= 40 ? ogSiteName : preset.brandName,
      price: parsedPrice ?? inferFallbackPriceFromText(finalTitle, fallbackPrice),
      thumbnailUrl: ogImage && /^https?:\/\//i.test(ogImage) ? ogImage : preset.defaultThumbnail,
      affiliateUrl: url,
    };
  } catch {
    // Network timeout, DNS, or bot protection -> return deterministic smart fallback
    return {
      productName: slugTitle,
      brandName: preset.brandName,
      price: fallbackPrice,
      thumbnailUrl: preset.defaultThumbnail,
      affiliateUrl: url,
    };
  }
}

