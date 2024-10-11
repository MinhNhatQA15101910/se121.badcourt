import { injectable } from "inversify";
import { IJwtService } from "../interfaces/IJwtService";
import * as jwt from "jsonwebtoken";
import { JWT_SECRET } from "../secrets";

@injectable()
export class JwtService implements IJwtService {
  generateToken(userId: any): string {
    return jwt.sign({ userId }, JWT_SECRET);
  }
}
