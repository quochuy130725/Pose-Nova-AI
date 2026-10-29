import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { sendSuccess } from '../../common/utils/response.util';
import { AppError } from '../../common/middlewares/error.middleware';

export class AuthController {
  static async demoLogin(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await AuthService.demoLogin(req.body);
      sendSuccess(
        res,
        result,
        `Switched persona to ${result.user.fullName} (${result.user.role})`,
        200,
      );
    } catch (err) {
      next(err);
    }
  }

  static async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await AuthService.register(req.body);
      sendSuccess(res, result, 'Account registered successfully', 201);
    } catch (err) {
      next(err);
    }
  }

  static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await AuthService.login(req.body);
      sendSuccess(res, result, 'Logged in successfully', 200);
    } catch (err) {
      next(err);
    }
  }

  static async getMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const profile = await AuthService.getMe(req.user.userId);
      sendSuccess(res, profile, 'Fetched authenticated user profile', 200);
    } catch (err) {
      next(err);
    }
  }
}

