import * as jwt from "jsonwebtoken";

export interface IJwtService {
  generateToken(payload: jwt.JwtPayload): string;
  getVerified(token: string): jwt.JwtPayload | string;
}
