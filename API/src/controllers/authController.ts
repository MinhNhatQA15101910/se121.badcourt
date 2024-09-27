import { inject, injectable } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { SignupSchema } from "../schemas/users";
import { BadRequestException } from "../exceptions/badRequestException";

@injectable()
export class AuthController {
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._userRepository = userRepository;
  }

  async signup(req: Request, res: Response) {
    const validatedData = SignupSchema.parse(req.body);

    const { username, email, password, role } = validatedData;

    let user = await this._userRepository.getUserByEmailAndRole(email, role);
    if (user) {
      throw new BadRequestException("User already exists!");
    }

    user = await this._userRepository.createUser({
      username,
      email,
      password,
      role,
    });

    res.json(user);
  }
}
