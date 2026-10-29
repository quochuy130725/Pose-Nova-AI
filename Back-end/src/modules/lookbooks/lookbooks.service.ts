import { Prisma } from '@prisma/client';
import { prisma } from '../../config/database';
import { AppError } from '../../common/middlewares/error.middleware';
import { scrapeProductMetadata } from '../../integrations/scraper/affiliate.scraper';
import { CreateLookbookInput } from './lookbooks.schema';

export class LookbooksService {
  /**
   * GET /api/v1/lookbooks
   * Supports optional ?styleCategory= filter and computes personalized `isLiked` status.
   */
  static async listLookbooks(params: { styleCategory?: string; currentUserId?: string }) {
    const categoryFilter = params.styleCategory?.trim();
    const where: Prisma.LookbookWhereInput =
      categoryFilter && categoryFilter.toUpperCase() !== 'ALL'
        ? { styleCategory: { equals: categoryFilter, mode: 'insensitive' } }
        : {};

    const lookbooks = await prisma.lookbook.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        stylist: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true,
            role: true,
            bio: true,
            ratingAvg: true,
            totalReviews: true,
            verifiedBadge: true,
          },
        },
        productTags: {
          orderBy: { productName: 'asc' },
        },
        likes: params.currentUserId
          ? {
              where: { userId: params.currentUserId },
              select: { id: true },
            }
          : false,
      },
    });

    return lookbooks.map((lb) => {
      const userLikes = Array.isArray(lb.likes) ? lb.likes : [];
      const { likes: _omittedLikes, ...rest } = lb;

      return {
        ...rest,
        productTags: lb.productTags.map((tag) => ({
          ...tag,
          price: Number(tag.price),
        })),
        isLiked: params.currentUserId ? userLikes.length > 0 : false,
      };
    });
  }

  /**
   * POST /api/v1/lookbooks/scrape-affiliate
   */
  static async scrapeAffiliate(url: string) {
    return scrapeProductMetadata(url);
  }

  /**
   * POST /api/v1/lookbooks
   * Validates 33-node skeletal array and creates Lookbook + nested ProductTags.
   */
  static async createLookbook(stylistId: string, input: CreateLookbookInput) {
    if (!Array.isArray(input.poseLandmarksJson) || input.poseLandmarksJson.length !== 33) {
      throw new AppError(
        'Invalid pose data: poseLandmarksJson must be an array of exactly 33 skeletal landmarks.',
        400,
      );
    }

    const normalizedLandmarks = input.poseLandmarksJson.map((node, index) => ({
      landmarkIndex: node.landmarkIndex ?? node.id ?? index,
      x: node.x,
      y: node.y,
      z: node.z ?? 0,
      visibility: node.visibility ?? 1.0,
    }));

    const created = await prisma.lookbook.create({
      data: {
        stylistId,
        title: input.title,
        description: input.description,
        styleCategory: input.styleCategory,
        imageUrl: input.imageUrl,
        poseLandmarksJson: normalizedLandmarks as Prisma.InputJsonValue,
        productTags:
          input.productTags.length > 0
            ? {
                create: input.productTags.map((tag) => ({
                  productName: tag.productName,
                  brandName: tag.brandName,
                  price: tag.price,
                  thumbnailUrl: tag.thumbnailUrl,
                  affiliateUrl: tag.affiliateUrl,
                  posX: tag.posX,
                  posY: tag.posY,
                })),
              }
            : undefined,
      },
      include: {
        stylist: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true,
            role: true,
            ratingAvg: true,
            verifiedBadge: true,
          },
        },
        productTags: true,
      },
    });

    return {
      ...created,
      productTags: created.productTags.map((tag) => ({
        ...tag,
        price: Number(tag.price),
      })),
      isLiked: false,
    };
  }

  /**
   * POST /api/v1/lookbooks/:id/like
   * Toggles LookbookLike record and updates likesCount atomically.
   */
  static async toggleLike(lookbookId: string, userId: string) {
    return prisma.$transaction(async (tx) => {
      const lookbook = await tx.lookbook.findUnique({
        where: { id: lookbookId },
        select: { id: true, likesCount: true },
      });

      if (!lookbook) {
        throw new AppError('Lookbook not found.', 404);
      }

      const existingLike = await tx.lookbookLike.findUnique({
        where: {
          lookbookId_userId: {
            lookbookId,
            userId,
          },
        },
      });

      if (existingLike) {
        await tx.lookbookLike.delete({
          where: { id: existingLike.id },
        });
        const nextCount = Math.max(0, lookbook.likesCount - 1);
        const updated = await tx.lookbook.update({
          where: { id: lookbookId },
          data: { likesCount: nextCount },
          select: { id: true, likesCount: true },
        });

        return {
          lookbookId: updated.id,
          isLiked: false,
          likesCount: updated.likesCount,
        };
      }

      await tx.lookbookLike.create({
        data: {
          lookbookId,
          userId,
        },
      });
      const updated = await tx.lookbook.update({
        where: { id: lookbookId },
        data: { likesCount: { increment: 1 } },
        select: { id: true, likesCount: true },
      });

      return {
        lookbookId: updated.id,
        isLiked: true,
        likesCount: updated.likesCount,
      };
    });
  }

  /**
   * POST /api/v1/lookbooks/tags/:tagId/click
   * Increments affiliate click counter and returns destination URL.
   */
  static async trackAffiliateTagClick(tagId: string) {
    const existingTag = await prisma.productTag.findUnique({
      where: { id: tagId },
    });

    if (!existingTag) {
      throw new AppError('Affiliate product tag not found.', 404);
    }

    const updated = await prisma.productTag.update({
      where: { id: tagId },
      data: { clickCount: { increment: 1 } },
    });

    return {
      tagId: updated.id,
      productName: updated.productName,
      brandName: updated.brandName,
      price: Number(updated.price),
      clickCount: updated.clickCount,
      affiliateUrl: updated.affiliateUrl,
    };
  }
}

