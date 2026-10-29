import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env';
import { sendError } from '../utils/response.util';

export interface AuthUserPayload {
  userId: string;
  email: string;
  role: 'CLIENT' | 'STYLIST' | 'ADMIN';
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUserPayload;
    }
  }
}

export function authenticate(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    sendError(res, 'Unauthorized: Missing or invalid token', 401);
    return;
  }

  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, env.JWT_SECRET) as AuthUserPayload;
    req.user = payload;
    next();
  } catch {
    sendError(res, 'Unauthorized: Token expired or invalid', 401);
  }
}

/**
 * Attaches req.user if a valid Bearer token is present, otherwise continues as guest.
 * Used on public feeds (e.g., GET /api/v1/lookbooks) to compute personalized `isLiked` state.
 */
export function optionalAuthenticate(req: Request, _res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      req.user = jwt.verify(token, env.JWT_SECRET) as AuthUserPayload;
    } catch {
      // Ignore invalid/expired token on optional-auth public routes
    }
  }
  next();
}

export function requireRole(...roles: AuthUserPayload['role'][]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      sendError(res, 'Unauthorized: Authentication required', 401);
      return;
    }
    if (!roles.includes(req.user.role)) {
      sendError(res, `Forbidden: Requires role [${roles.join(', ')}]`, 403);
      return;
    }
    next();
  };
}
