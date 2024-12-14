import { inject, injectable } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { IJwtService } from "../interfaces/services/IJwt.service";
import { IMailService } from "../interfaces/services/IMail.service";
import { SignupSchema } from "../schemas/auth/signup.schema";
import { LoginSchema } from "../schemas/auth/login.schema";
import { ValidateEmailSchema } from "../schemas/auth/validateEmail.schema";
import { SendVerifyEmailSchema } from "../schemas/auth/sendVerifyEmail.schema";
import { ChangePasswordSchema } from "../schemas/auth/changePassword.schema";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { UserDto } from "../dtos/user.dto";
import _ from "lodash";

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

  async login(req: Request, res: Response) {
    const loginDto = LoginSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmailAndRole(
      loginDto.email,
      loginDto.role
    );
    if (!user) {
      throw new UnauthorizedException(
        `${
          loginDto.role == "player" ? "Player" : "Manager"
        } with this email does not exist.`
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

    const userDto = new UserDto();
    _.assign(userDto, _.pick(user, _.keys(userDto)));
    userDto.token = token;
    if (user.image) userDto.imageUrl = user.image.url;

    res.json(userDto);
  }

  async loginWithGoogle(req: Request, res: Response) {
    const signupDto = SignupSchema.parse(req.body);

    const existingUser = await this._userRepository.getUserByEmailAndRole(
      signupDto.email,
      "player"
    );

    if (existingUser) {
      const token = this._jwtService.generateToken(existingUser._id);

      const userDto = new UserDto();
      _.assign(userDto, _.pick(existingUser, _.keys(userDto)));
      userDto.token = token;
      if (existingUser.image) userDto.imageUrl = existingUser.image.url;

      res.json(userDto);
    }

    const user = await this._userRepository.signupUser(signupDto);
    const token = this._jwtService.generateToken(existingUser._id);

    const userDto = new UserDto();
    _.assign(userDto, _.pick(user, _.keys(userDto)));
    userDto.token = token;
    if (user.image) userDto.imageUrl = user.image.url;

    res.json(userDto);
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

  async changePassword(req: Request, res: Response) {
    const changePasswordDto = ChangePasswordSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmailAndRole(
      changePasswordDto.email,
      changePasswordDto.role
    );
    if (!user) {
      throw new BadRequestException("User with this email does not exist.");
    }

    user.password = this._bcryptService.hashPassword(
      changePasswordDto.newPassword
    );
    await user.save();

    res.status(204).send();
  }

  async validateToken(req: Request, res: Response) {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.json(false);
    }

    try {
      const verified = this._jwtService.getVerified(token);
      if (!verified) {
        return res.json(false);
      }

      const user = await this._userRepository.getUserById((verified as any).id);
      if (!user) {
        return res.json(false);
      }

      res.json(true);
    } catch {
      return res.json(false);
    }
  }
}
