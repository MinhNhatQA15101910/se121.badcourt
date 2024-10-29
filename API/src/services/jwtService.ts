import { injectable } from "inversify";
import { IJwtService } from "../interfaces/services/IJwtService";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";

@injectable()
export class JwtService implements IJwtService {
  generateToken(userId: any): string {
    return jwt.sign({ id: userId }, JWT_SECRET);
  }

  getVerified(token: string): jwt.JwtPayload | string {
    return jwt.verify(token, JWT_SECRET);
  }
}
