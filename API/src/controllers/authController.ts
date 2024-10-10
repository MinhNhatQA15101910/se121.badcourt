import { inject, injectable } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import {
  LoginSchema,
  SignupSchema,
  ValidateEmailSchema,
} from "../schemas/users";
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
    const { username, email, password, role } = SignupSchema.parse(req.body);

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
    const { email, password } = LoginSchema.parse(req.body);

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

  async loginAsManager(req: Request, res: Response) {
    const { email, password } = LoginSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmailAndRole(
      email,
      "manager"
    );
    if (!user) {
      throw new UnauthorizedException(
        "Manager with this email does not exist."
      );
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

  async loginWithGoogle(req: Request, res: Response) {
    const { username, email, password, imageUrl } = SignupSchema.parse(
      req.body
    );

    const existingUser = await this._userRepository.getUserByEmailAndRole(
      email,
      "player"
    );

    if (existingUser) {
      const token = this._jwtService.generateToken(existingUser._id);
      return res.json({ ...existingUser._doc, token });
    }

    const user = await this._userRepository.createUser({
      username,
      email,
      password,
      imageUrl,
      role: "player",
    });

    const token = this._jwtService.generateToken(user._id);
    res.json({ ...user._doc, token });
  }

  async validateEmail(req: Request, res: Response) {
    const { email } = ValidateEmailSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmail(email);
    if (user) {
      return res.json(true);
    }

    res.json(false);
  }
}
