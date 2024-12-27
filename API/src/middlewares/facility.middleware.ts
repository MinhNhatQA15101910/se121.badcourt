import { Request, Response, NextFunction } from "express";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";
import User from "../models/user";
import Facility from "../models/facility";

export const facilityMiddleware = async (
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

    const user = await User.findById((verified as any).userId);
    if (!user) {
      next(new UnauthorizedException("Unauthorized"));
    }

    const facility = await Facility.findById((verified as any).facilityId);
    if (!facility) {
      next(new UnauthorizedException("Unauthorized"));
    }

    if (facility!.userId.toString() !== user!._id.toString()) {
      next(new UnauthorizedException("Unauthorized"));
    }

    req.user = user;
    req.facility = facility;

    next();
  } catch (error) {
    next(new UnauthorizedException("Unauthorized"));
  }
};
