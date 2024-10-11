import { inject, injectable } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { BadRequestException } from "../exceptions/badRequestException";
import { UnauthorizedException } from "../exceptions/unauthorizedException";
import { IBcryptService } from "../interfaces/IBcryptService";
import { IJwtService } from "../interfaces/IJwtService";
import { IMailService } from "../interfaces/IMailService";
import { SignupSchema } from "../schemas/auth/signUp";
import { LoginSchema } from "../schemas/auth/login";
import { ValidateEmailSchema } from "../schemas/auth/validateEmail";
import { SendVerifyEmailSchema } from "../schemas/auth/sendVerifyEmail";

@injectable()
export class AuthController {
  private _bcryptService: IBcryptService;
  private _jwtService: IJwtService;
  private _mailService: IMailService;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.BcryptService) bcryptService: IBcryptService,
    @inject(INTERFACE_TYPE.JwtService) jwtService: IJwtService,
    @inject(INTERFACE_TYPE.MailService) mailService: IMailService,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._bcryptService = bcryptService;
    this._jwtService = jwtService;
    this._mailService = mailService;
    this._userRepository = userRepository;
  }

  async signup(req: Request, res: Response) {
    const signupDto = SignupSchema.parse(req.body);

    let user = await this._userRepository.getUserByEmailAndRole(
      signupDto.email,
      signupDto.role
    );
    if (user) {
      throw new BadRequestException("User already exists!");
    }

    user = await this._userRepository.signupUser(signupDto);

    res.json(user);
  }

  async loginAsPlayer(req: Request, res: Response) {
    const loginDto = LoginSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmailAndRole(
      loginDto.email,
      "player"
    );
    if (!user) {
      throw new UnauthorizedException("Player with this email does not exist.");
    }

    const isPasswordMatch = this._bcryptService.comparePassword(
      loginDto.password,
      user.password
    );
    if (!isPasswordMatch) {
      throw new UnauthorizedException("Incorrect password.");
    }

    const token = this._jwtService.generateToken(user._id);

    res.json({ ...user._doc, token });
  }

  async loginAsManager(req: Request, res: Response) {
    const loginDto = LoginSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmailAndRole(
      loginDto.email,
      "manager"
    );
    if (!user) {
      throw new UnauthorizedException(
        "Manager with this email does not exist."
      );
    }

    const isPasswordMatch = this._bcryptService.comparePassword(
      loginDto.password,
      user.password
    );
    if (!isPasswordMatch) {
      throw new UnauthorizedException("Incorrect password.");
    }

    const token = this._jwtService.generateToken(user._id);

    res.json({ ...user._doc, token });
  }

  async loginWithGoogle(req: Request, res: Response) {
    const signUpDto = SignupSchema.parse(req.body);

    const existingUser = await this._userRepository.getUserByEmailAndRole(
      signUpDto.email,
      "player"
    );

    if (existingUser) {
      const token = this._jwtService.generateToken(existingUser._id);
      return res.json({ ...existingUser._doc, token });
    }

    const user = await this._userRepository.signupUser(signUpDto);

    const token = this._jwtService.generateToken(user._id);
    res.json({ ...user._doc, token });
  }

  async validateEmail(req: Request, res: Response) {
    const validateEmailDto = ValidateEmailSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmail(
      validateEmailDto.email
    );
    if (user) {
      return res.json(true);
    }

    res.json(false);
  }

  sendVerifyEmail(req: Request, res: Response) {
    const sendVerifyEmailDto = SendVerifyEmailSchema.parse(req.body);

    this._mailService.sendVerifyEmail(
      sendVerifyEmailDto.email,
      sendVerifyEmailDto.pincode,
      (err, info) => {
        if (err) {
          throw new Error(err.message);
        }

        res.json("Email sent: " + info.response);
      }
    );
  }
}
