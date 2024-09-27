import { injectable } from "inversify";
import { IBcryptService } from "../interfaces/IBcryptService";
import { compareSync } from "bcrypt";

@injectable()
export class BcryptService implements IBcryptService {
  comparePassword(password: string, hash: string): boolean {
    return compareSync(password, hash);
  }
}
