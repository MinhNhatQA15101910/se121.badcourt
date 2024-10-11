import { injectable } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { hashSync } from "bcrypt";
import { SALT_ROUNDS } from "../secrets";
import User from "../models/user";
import { SignupDto } from "../schemas/auth/signup";

@injectable()
export class UserRepository implements IUserRepository {
  async getUserByEmail(email: string): Promise<any> {
    const user = await User.findOne({ email });
    return user;
  }

  async getUserByEmailAndRole(email: string, role: string): Promise<any> {
    const user = await User.findOne({ email, role });
    return user;
  }

  async getUserById(id: string): Promise<any> {
    const user = await User.findById(id);
    return user;
  }

  async signupUser(signupDto: SignupDto): Promise<any> {
    let user = new User({
      username: signupDto.username,
      email: signupDto.email,
      imageUrl: signupDto.imageUrl,
      password: hashSync(signupDto.password, +SALT_ROUNDS),
      role: signupDto.role,
    });
    user = await user.save();
    return user;
  }
}
