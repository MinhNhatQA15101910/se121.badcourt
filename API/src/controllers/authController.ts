import { inject, injectable } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { LoginSchema, SignupSchema } from "../schemas/users";
import { BadRequestException } from "../exceptions/badRequestException";
import { UnauthorizedException } from "../exceptions/unauthorizedException";
import { IBcryptService } from "../interfaces/IBcryptService";
import { IJwtService } from "../interfaces/IJwtService";

@injectable()
export class AuthController {
  private _bcryptService: IBcryptService;
  private _jwtService: IJwtService;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.BcryptService) bcryptService: IBcryptService,
    @inject(INTERFACE_TYPE.JwtService) jwtService: IJwtService,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._bcryptService = bcryptService;
    this._jwtService = jwtService;
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

  async loginAsPlayer(req: Request, res: Response) {
    const validatedData = LoginSchema.parse(req.body);

    const { email, password } = validatedData;

    const user = await this._userRepository.getUserByEmailAndRole(
      email,
      "player"
    );
    if (!user) {
      throw new UnauthorizedException("Player with this email does not exist.");
    }

    const isPasswordMatch = this._bcryptService.comparePassword(
      password,
      user.password
    );
    if (!isPasswordMatch) {
      throw new UnauthorizedException("Incorrect password.");
    }

    const token = this._jwtService.generateToken(user._id);

    res.json({ ...user._doc, token });
  }
}
