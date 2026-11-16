// Production Auth Guard & Token Verification Middleware (TypeScript)
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthenticatedUser {
  userId: string;
  tenantId: string;
  roles: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

export const requireAuth = (publicKeyPem: string) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'UNAUTHORIZED', message: 'Missing or malformed Authorization header' });
      return;
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, publicKeyPem, {
        algorithms: ['RS256', 'EdDSA'],
        issuer: 'https://auth.example.com',
      }) as AuthenticatedUser;

      req.user = decoded;
      next();
    } catch (err: any) {
      if (err.name === 'TokenExpiredError') {
        res.status(401).json({ error: 'TOKEN_EXPIRED', message: 'Access token expired, refresh required' });
        return;
      }
      res.status(401).json({ error: 'INVALID_TOKEN', message: 'Token signature or claims invalid' });
    }
  };
};
