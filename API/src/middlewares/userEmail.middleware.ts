import { Request, Response, NextFunction } from "express";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";
import User from "../models/user";

export const userEmailMiddleware = async (
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

    const user = await User.findOne({
      email: (verified as any).email,
      role: (verified as any).role,
    });
    if (!user) {
      next(new UnauthorizedException("Unauthorized"));
    }

    req.user = user;

    next();
  } catch (error) {
    next(new UnauthorizedException("Unauthorized"));
  }
};
