import { Response, NextFunction } from "express";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";

export const managerMiddleware = async (
  req: any,
  _res: Response,
  next: NextFunction
) => {
  const user = req.user;
  if (user.role !== "manager") {
    next(new UnauthorizedException("Unauthorized"));
  }

  next();
};
