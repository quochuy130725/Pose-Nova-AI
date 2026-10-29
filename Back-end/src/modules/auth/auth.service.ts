import bcrypt from 'bcryptjs';
import jwt, { SignOptions } from 'jsonwebtoken';
import { Role, User, Wallet } from '@prisma/client';
import { prisma } from '../../config/database';
import { env } from '../../config/env';
import { AppError } from '../../common/middlewares/error.middleware';
import { DemoLoginInput, LoginInput, RegisterInput } from './auth.schema';

type UserWithWallet = User & { wallet: Wallet | null };

function sanitizeUser(user: UserWithWallet) {
  const { passwordHash: _omitted, ...safeUser } = user;
  return {
    ...safeUser,
    wallet: user.wallet
      ? {
          ...user.wallet,
          availableBalance: Number(user.wallet.availableBalance),
          escrowLockedBalance: Number(user.wallet.escrowLockedBalance),
          totalWithdrawn: Number(user.wallet.totalWithdrawn),
        }
      : null,
  };
}

function signAuthToken(user: Pick<User, 'id' | 'email' | 'role'>): string {
  const options: SignOptions = {
    expiresIn: env.JWT_EXPIRES_IN as SignOptions['expiresIn'],
  };
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role,
    },
    env.JWT_SECRET,
    options,
  );
}

export class AuthService {
  /**
   * 1-Tap Role Switcher (Fast-Track Auth for Alex Đỗ & Maya Trần)
   */
  static async demoLogin(input: DemoLoginInput) {
    if (!env.ENABLE_DEMO_LOGIN) {
      throw new AppError('Demo fast-track login is disabled in this environment.', 403);
    }

    const targetEmail =
      input.role === 'STYLIST' ? 'maya.tran@posenova.com' : 'alex.do@gmail.com';

    const user = await prisma.user.findUnique({
      where: { email: targetEmail },
      include: { wallet: true },
    });

    if (!user) {
      throw new AppError(
        `Seeded demo user (${targetEmail}) not found. Please run 'npm run db:seed' first.`,
        404,
      );
    }

    const token = signAuthToken(user);
    return {
      token,
      user: sanitizeUser(user),
    };
  }

  /**
   * Standard User Registration (Creates User + Zero-Balance Wallet in ACID Transaction)
   */
  static async register(input: RegisterInput) {
    const existing = await prisma.user.findUnique({
      where: { email: input.email },
    });
    if (existing) {
      throw new AppError('Email is already registered.', 409);
    }

    const passwordHash = await bcrypt.hash(input.password, 10);

    const createdUser = await prisma.$transaction(async (tx) => {
      return tx.user.create({
        data: {
          email: input.email,
          passwordHash,
          fullName: input.fullName,
          role: input.role as Role,
          heightCm: input.heightCm,
          weightKg: input.weightKg,
          avatarUrl: input.avatarUrl,
          bio: input.bio,
          wallet: {
            create: {
              availableBalance: 0,
              escrowLockedBalance: 0,
              totalWithdrawn: 0,
            },
          },
        },
        include: { wallet: true },
      });
    });

    const token = signAuthToken(createdUser);
    return {
      token,
      user: sanitizeUser(createdUser),
    };
  }

  /**
   * Standard Email + Password Login
   */
  static async login(input: LoginInput) {
    const user = await prisma.user.findUnique({
      where: { email: input.email },
      include: { wallet: true },
    });

    if (!user || !user.passwordHash) {
      throw new AppError('Invalid email or password.', 401);
    }

    const isPasswordValid = await bcrypt.compare(input.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError('Invalid email or password.', 401);
    }

    const token = signAuthToken(user);
    return {
      token,
      user: sanitizeUser(user),
    };
  }

  /**
   * Current Authenticated User Profile + Wallet Balances
   */
  static async getMe(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { wallet: true },
    });

    if (!user) {
      throw new AppError('User profile not found.', 404);
    }

    return sanitizeUser(user);
  }
}

