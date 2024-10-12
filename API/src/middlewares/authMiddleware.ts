import { Request, Response, NextFunction } from "express";
import { UnauthorizedException } from "../exceptions/unauthorizedException";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";
import User from "../models/user";

export const authMiddleware = async (
  req: Request,
  _res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    next(new UnauthorizedException("Unauthorized"));
  }

  try {
    const verified = jwt.verify(token!, JWT_SECRET);
    if (!verified) {
      next(new UnauthorizedException("Unauthorized"));
    }

    const user = await User.findById((verified as any).id);
    if (!user) {
      next(new UnauthorizedException("Unauthorized"));
    }

    (req as any).user = user!;

    next();
  } catch (error) {
    next(new UnauthorizedException("Unauthorized"));
  }
};
