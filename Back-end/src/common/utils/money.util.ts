import {
  STAGE_SPLITS,
  PLATFORM_FEE_RATE,
  STYLIST_NET_RATE,
  MILESTONE_STAGE_TEMPLATES,
} from '../constants/escrow.constants';

export interface StageFinancialBreakdown {
  stageOrder: number;
  title: string;
  description: string;
  percentage: number;
  grossAmount: number;
  feeAmount: number;
  netPayout: number;
}

/**
 * Calculates exact VND amounts for a 3-stage 30-30-40 contract,
 * strictly preserving the financial invariant:
 * Total Budget = Sum(Gross) = Sum(Fee) + Sum(Net Payout).
 */
export function calculateMilestoneBreakdown(totalBudgetVnd: number): StageFinancialBreakdown[] {
  const budget = Math.round(totalBudgetVnd);
  const stage1Gross = Math.round(budget * STAGE_SPLITS[0]);
  const stage2Gross = Math.round(budget * STAGE_SPLITS[1]);
  const stage3Gross = budget - stage1Gross - stage2Gross;

  const grossList = [stage1Gross, stage2Gross, stage3Gross];

  return MILESTONE_STAGE_TEMPLATES.map((tpl, index) => {
    const grossAmount = grossList[index];
    const feeAmount = Math.round(grossAmount * PLATFORM_FEE_RATE);
    const netPayout = grossAmount - feeAmount;

    return {
      stageOrder: tpl.stageOrder,
      title: tpl.title,
      description: tpl.description,
      percentage: tpl.percentage,
      grossAmount,
      feeAmount,
      netPayout,
    };
  });
}

export function calculateStylistNetTotal(totalBudgetVnd: number): number {
  return Math.round(totalBudgetVnd * STYLIST_NET_RATE);
}

export function calculatePlatformFeeTotal(totalBudgetVnd: number): number {
  return Math.round(totalBudgetVnd) - calculateStylistNetTotal(totalBudgetVnd);
}

