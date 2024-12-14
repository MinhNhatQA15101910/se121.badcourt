import { inject, injectable } from "inversify";
import { SignupDto } from "../schemas/auth/signup.schema";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import User from "../models/user";
import { FileDto } from "../dtos/file.dto";

@injectable()
export class UserRepository implements IUserRepository {
  private _bcryptService: IBcryptService;

  constructor(
    @inject(INTERFACE_TYPE.BcryptService) bcryptService: IBcryptService
  ) {
    this._bcryptService = bcryptService;
  }

  async addPhoto(
    userId: string,
    fileDto: FileDto
  ): Promise<FileDto | undefined> {
    let user = await User.findById(userId);

    if (!user) {
      return undefined;
    }

    user.image = fileDto;
    user = await user.save();

    return fileDto;
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
    return await User.findById(id);
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
