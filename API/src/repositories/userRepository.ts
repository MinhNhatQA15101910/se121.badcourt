import { inject, injectable } from "inversify";
import { SignupDto } from "../schemas/auth/signup";
import { IBcryptService } from "../interfaces/services/IBcryptService";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IUserRepository } from "../interfaces/repositories/IUserRepository";
import User from "../models/user";

@injectable()
export class UserRepository implements IUserRepository {
  private _bcryptService: IBcryptService;

  constructor(
    @inject(INTERFACE_TYPE.BcryptService) bcryptService: IBcryptService
  ) {
    this._bcryptService = bcryptService;
  }

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
    let user = await User.create({
      username: signupDto.username,
      email: signupDto.email,
      imageUrl: signupDto.imageUrl,
      password: this._bcryptService.hashPassword(signupDto.password),
      role: signupDto.role,
    });
    user = await user.save();
    return user;
  }
}
