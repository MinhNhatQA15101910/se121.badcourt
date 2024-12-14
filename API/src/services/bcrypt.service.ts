import { injectable } from "inversify";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { compareSync, hashSync } from "bcrypt";
import { SALT_ROUNDS } from "../secrets";

@injectable()
export class BcryptService implements IBcryptService {
  comparePassword(password: string, hash: string): boolean {
    return compareSync(password, hash);
  }

  hashPassword(password: string): string {
    return hashSync(password, +SALT_ROUNDS);
  }
}
