import { ExtendedError, Socket } from "socket.io";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";
import User from "../models/user";

export const websocketsMiddleware = async (
  socket: Socket,
  next: (err?: ExtendedError) => void
) => {
  const authHeader = socket.handshake.headers.authorization;
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

    next();
  } catch (error) {
    next(new UnauthorizedException("Unauthorized"));
  }
};
