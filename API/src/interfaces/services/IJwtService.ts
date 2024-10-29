import * as jwt from "jsonwebtoken";

export interface IJwtService {
  generateToken(userId: any): string;
  getVerified(token: string): jwt.JwtPayload | string;
}
