import { injectable } from "inversify";
import { IJwtService } from "../interfaces/services/IJwt.service";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";

@injectable()
export class JwtService implements IJwtService {
  generateToken(payload: jwt.JwtPayload): string {
    return jwt.sign(payload, JWT_SECRET);
  }

  getVerified(token: string): jwt.JwtPayload | string {
    return jwt.verify(token, JWT_SECRET);
  }
}
