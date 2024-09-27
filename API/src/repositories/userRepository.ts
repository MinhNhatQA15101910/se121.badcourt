import { injectable } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { hashSync } from "bcrypt";
import { SALT_ROUNDS } from "../secrets";
import User from "../models/user";

@injectable()
export class UserRepository implements IUserRepository {
  async createUser(userData: any): Promise<any> {
    let user = new User({
      username: userData.username,
      email: userData.email,
      password: hashSync(userData.password, +SALT_ROUNDS),
      role: userData.role,
    });
    user = await user.save();
    return user;
  }

  async getUserByEmailAndRole(email: string, role: string): Promise<any> {
    const user = await User.findOne({ email, role });
    return user;
  }
}
