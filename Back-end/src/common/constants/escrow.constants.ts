export const STAGE_SPLITS = [0.30, 0.30, 0.40] as const;
export const PLATFORM_FEE_RATE = 0.15; // 15% Platform Commission
export const STYLIST_NET_RATE = 0.85;  // 85% Stylist Net Payout
export const MAX_REVISIONS = 2;        // Max 2 free revisions per stage
export const SLA_HOURS = 48;           // 48 hours auto-release SLA timer

export const MILESTONE_STAGE_TEMPLATES = [
  {
    stageOrder: 1,
    title: 'Stage 1: Moodboard & Concept Study',
    percentage: 30,
    description: 'Moodboard & Concept (color palette, vibe, silhouette direction)',
  },
  {
    stageOrder: 2,
    title: 'Stage 2: Outfit Selection & Smart Tagging',
    percentage: 30,
    description: 'Outfit Selection & Affiliate Tags (garment curation and shoppable links)',
  },
  {
    stageOrder: 3,
    title: 'Stage 3: Final Custom Lookbook & ML Kit Poses',
    percentage: 40,
    description: 'Final Lookbook & 33 AI Pose Nodes (visual guide and custom skeleton)',
  },
] as const;

