import { GoogleGenerativeAI } from '@google/generative-ai';
import { env } from '../../config/env';

export interface EnhanceBriefInput {
  heightCm: number;
  weightKg: number;
  occasion: string;
  vibe?: string;
  bodyType?: string;
  briefText?: string;
  totalBudget?: number;
}

export interface EnhancedBriefResult {
  enhancedBrief: string;
  suggestedPalette: [string, string, string, string];
  colorPalette: [string, string, string, string];
  recommendedStyle: string;
  bodyProportionTip: string;
  provider: 'gemini-1.5-flash' | 'posenova-stylist-fallback';
  latencyMs: number;
}

const HEX_COLOR_REGEX = /^#[0-9A-Fa-f]{6}$/;
const GEMINI_TIMEOUT_MS = 2400; // Strictly under 3000ms SLA

interface StylePreset {
  style: string;
  palette: [string, string, string, string];
  fabricNote: string;
}

function selectStylePreset(text: string): StylePreset {
  const lower = text.toLowerCase();

  if (/cyber|concert|festival|rave|club|neon|party|đêm|nhạc/.test(lower)) {
    return {
      style: 'CYBER_AW26',
      palette: ['#09090B', '#F43F5E', '#10B981', '#A855F7'],
      fabricNote:
        'technical nylon outerwear, matte charcoal cargo layers, and reflective metallic/neon accents',
    };
  }

  if (/wedding|date|dinner|gala|old money|classic|tiệc|cưới|hẹn hò|sang trọng/.test(lower)) {
    return {
      style: 'OLD_MONEY',
      palette: ['#1C1917', '#F5F5F4', '#92400E', '#1E3A8A'],
      fabricNote:
        'structured wool-linen tailoring, crisp ivory shirting, and tonal leather accessories',
    };
  }

  if (/office|work|business|interview|minimal|công sở|đi làm|họp|tối giản/.test(lower)) {
    return {
      style: 'MINIMALIST',
      palette: ['#18181B', '#F4F4F5', '#D6D3D1', '#78716C'],
      fabricNote:
        'clean monochrome tailoring,relaxed pleated trousers, and architectural monochrome layering',
    };
  }

  if (/y2k|retro|vintage|cafe|cà phê|chụp hình|photoshoot/.test(lower)) {
    return {
      style: 'Y2K',
      palette: ['#111827', '#EC4899', '#A855F7', '#E5E7EB'],
      fabricNote:
        'cropped boxy silhouettes, washed denim textures, and statement contrast trims',
    };
  }

  return {
    style: 'STREETWEAR',
    palette: ['#0F172A', '#E2E8F0', '#38BDF8', '#F97316'],
    fabricNote:
      'boxy heavyweight cotton layers, wide-tapered bottoms, and structured street sneakers',
  };
}

function buildBodyProportionTip(heightCm: number, weightKg: number, bodyType?: string): string {
  const heightM = heightCm / 100;
  const bmi = weightKg / (heightM * heightM);

  let proportionRule: string;
  if (heightCm < 165) {
    proportionRule =
      'rule-of-thirds high-waisted trousers with a cropped boxy outer layer to elongate vertical leg line';
  } else if (heightCm >= 178) {
    proportionRule =
      'longline oversized layering with relaxed wide-leg draping to balance tall vertical proportions';
  } else if (bmi >= 24.5) {
    proportionRule =
      'structured drop-shoulder outerwear in matte dark tones with vertical seam lines for a sharp silhouette';
  } else if (bmi < 19.5) {
    proportionRule =
      'textured multi-layering (heavyweight knit/bomber over tee) to add clean visual volume to upper torso';
  } else {
    proportionRule =
      'balanced 1:2 top-to-bottom silhouette with structured shoulders and relaxed straight-fit trousers';
  }

  return bodyType
    ? `Tailored for ${heightCm}cm / ${weightKg}kg (${bodyType}): ${proportionRule}.`
    : `Tailored for ${heightCm}cm / ${weightKg}kg: ${proportionRule}.`;
}

function buildSmartFallback(input: EnhanceBriefInput, startedAt: number): EnhancedBriefResult {
  const combinedContext = `${input.occasion} ${input.vibe ?? ''} ${input.briefText ?? ''}`;
  const preset = selectStylePreset(combinedContext);
  const bodyTip = buildBodyProportionTip(input.heightCm, input.weightKg, input.bodyType);
  const userSeed = input.briefText?.trim()
    ? `Client note: "${input.briefText.trim()}". `
    : '';
  const vibeLabel = input.vibe?.trim() || preset.style;

  const enhancedBrief =
    `[${vibeLabel} Styling Brief — ${input.occasion}] ${userSeed}` +
    `${bodyTip} Prioritize ${preset.fabricNote}. ` +
    `Include low-angle 33-landmark pose guidance to maximize posture confidence on camera.`;

  return {
    enhancedBrief,
    suggestedPalette: preset.palette,
    colorPalette: preset.palette,
    recommendedStyle: preset.style,
    bodyProportionTip: bodyTip,
    provider: 'posenova-stylist-fallback',
    latencyMs: Date.now() - startedAt,
  };
}

function normalizePalette(
  raw: unknown,
  fallback: [string, string, string, string],
): [string, string, string, string] {
  if (!Array.isArray(raw)) return fallback;
  const valid = raw
    .map((item) => (typeof item === 'string' ? item.trim().toUpperCase() : ''))
    .filter((hex) => HEX_COLOR_REGEX.test(hex));

  if (valid.length >= 4) {
    return [valid[0], valid[1], valid[2], valid[3]];
  }
  return fallback;
}

export class GeminiService {
  static async enhanceStylingBrief(input: EnhanceBriefInput): Promise<EnhancedBriefResult> {
    const startedAt = Date.now();
    const fallbackResult = buildSmartFallback(input, startedAt);

    const apiKey = env.GEMINI_API_KEY?.trim();
    if (!apiKey || apiKey.includes('your_gemini_api_key')) {
      return {
        ...fallbackResult,
        latencyMs: Date.now() - startedAt,
      };
    }

    try {
      const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({
        model: 'gemini-1.5-flash',
        generationConfig: {
          responseMimeType: 'application/json',
          temperature: 0.65,
        },
      });

      const prompt = `You are an elite personal fashion stylist on PoseNova AI.
Analyze the client's metrics and occasion, then return ONLY valid JSON with exact keys:
{
  "enhancedBrief": "concise 2-3 sentence professional styling brief tailored to height, weight, and occasion",
  "suggestedPalette": ["#HEX1", "#HEX2", "#HEX3", "#HEX4"],
  "recommendedStyle": "ONE OF: STREETWEAR, MINIMALIST, CYBER_AW26, OLD_MONEY, Y2K",
  "bodyProportionTip": "1 concise sentence on silhouette ratio for ${input.heightCm}cm / ${input.weightKg}kg"
}

Client profile:
- Height: ${input.heightCm} cm
- Weight: ${input.weightKg} kg
- Body Type: ${input.bodyType ?? 'Standard'}
- Occasion: ${input.occasion}
- Preferred Vibe: ${input.vibe ?? 'Modern Editorial'}
- Initial Notes: ${input.briefText ?? 'None'}
- Budget (VND): ${input.totalBudget ?? 2500000}`;

      const geminiPromise = model.generateContent(prompt);
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('Gemini SLA timeout (2400ms)')), GEMINI_TIMEOUT_MS);
      });

      const response = await Promise.race([geminiPromise, timeoutPromise]);
      const rawText = response.response.text();
      const parsed = JSON.parse(rawText) as {
        enhancedBrief?: string;
        suggestedPalette?: unknown;
        recommendedStyle?: string;
        bodyProportionTip?: string;
      };

      const palette = normalizePalette(parsed.suggestedPalette, fallbackResult.suggestedPalette);
      const enhancedBrief =
        typeof parsed.enhancedBrief === 'string' && parsed.enhancedBrief.trim().length > 10
          ? parsed.enhancedBrief.trim()
          : fallbackResult.enhancedBrief;

      return {
        enhancedBrief,
        suggestedPalette: palette,
        colorPalette: palette,
        recommendedStyle:
          typeof parsed.recommendedStyle === 'string' && parsed.recommendedStyle.trim()
            ? parsed.recommendedStyle.trim().toUpperCase()
            : fallbackResult.recommendedStyle,
        bodyProportionTip:
          typeof parsed.bodyProportionTip === 'string' && parsed.bodyProportionTip.trim()
            ? parsed.bodyProportionTip.trim()
            : fallbackResult.bodyProportionTip,
        provider: 'gemini-1.5-flash',
        latencyMs: Date.now() - startedAt,
      };
    } catch {
      // Resilient fallback guarantees < 3s response and 0 demo failures
      return {
        ...fallbackResult,
        latencyMs: Date.now() - startedAt,
      };
    }
  }
}

