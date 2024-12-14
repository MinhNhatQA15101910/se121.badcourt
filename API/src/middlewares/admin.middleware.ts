import { Response, NextFunction } from "express";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";

export const adminMiddleware = async (
  req: any,
  _res: Response,
  next: NextFunction
) => {
  const user = req.user;
  if (user.role !== "admin") {
    next(new UnauthorizedException("Unauthorized"));
  }

  next();
};
