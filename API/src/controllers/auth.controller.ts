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
import { ChangePasswordSchema } from "../schemas/auth/changePassword.schema";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { UserDto } from "../dtos/user.dto";
import { VerifyPincodeSchema } from "../schemas/auth/verifyPincode.schema";

const pincodeMap = new Map();
const validateUserMap = new Map();

function generatePincode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

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

  async validateSignup(req: Request, res: Response) {
    const signupDto = SignupSchema.parse(req.body);

    let user = await this._userRepository.getUserByEmailAndRole(
      signupDto.email,
      signupDto.role
    );
    if (user) {
      throw new BadRequestException("User already exists!");
    }

    const pincode = generatePincode();
    let pincodeSubMap = new Map();
    pincodeSubMap.set(signupDto.role, pincode);
    pincodeMap.set(signupDto.email, pincodeSubMap);
    console.log("Pincode Map: ", pincodeMap);

    let userSubMap = new Map();
    userSubMap.set(signupDto.role, signupDto);
    validateUserMap.set(signupDto.email, userSubMap);
    console.log("Validate User Map: ", validateUserMap);

    this._mailService.sendVerifyEmail(signupDto.email, pincode, (err, info) => {
      if (err) {
        throw new Error(err.message);
      }

      console.log("Email sent: " + info.response);
    });

    res.json({
      token: this._jwtService.generateToken({
        email: signupDto.email,
        role: signupDto.role,
        action: "signup",
      }),
    });
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
          loginDto.role == "player"
            ? "Player"
            : loginDto.role === "manager"
            ? "Manager"
            : "Admin"
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

    const token = this._jwtService.generateToken({ id: user._id });

    const userDto = UserDto.mapFrom(user);
    userDto.token = token;

    res.json(userDto);
  }

  async loginWithGoogle(req: Request, res: Response) {
    const signupDto = SignupSchema.parse(req.body);

    const existingUser = await this._userRepository.getUserByEmailAndRole(
      signupDto.email,
      "player"
    );

    if (existingUser) {
      const token = this._jwtService.generateToken({ id: existingUser._id });

      const userDto = UserDto.mapFrom(existingUser);
      userDto.token = token;

      res.json(userDto);
    }

    const user = await this._userRepository.signupUser(signupDto);
    const token = this._jwtService.generateToken({ id: existingUser._id });

    const userDto = UserDto.mapFrom(user);
    userDto.token = token;

    res.json(userDto);
  }

  async validateEmail(req: Request, res: Response) {
    const validateEmailDto = ValidateEmailSchema.parse(req.body);

    const user = await this._userRepository.getUserByEmailAndRole(
      validateEmailDto.email,
      validateEmailDto.role
    );
    if (user) {
      const pincode = generatePincode();
      let pincodeSubMap = new Map();
      pincodeSubMap.set(validateEmailDto.role, pincode);
      pincodeMap.set(validateEmailDto.email, pincodeSubMap);

      this._mailService.sendVerifyEmail(
        validateEmailDto.email,
        pincode,
        (err, info) => {
          if (err) {
            throw new Error(err.message);
          }

          console.log("Email sent: " + info.response);
        }
      );

      return res.json({
        token: this._jwtService.generateToken({
          email: validateEmailDto.email,
          role: validateEmailDto.role,
          action: "verifyEmail",
        }),
      });
    }

    res.json(false);
  }

  async verifyPincode(req: Request, res: Response) {
    const verifyPincodeSchema = VerifyPincodeSchema.parse(req.body);
    const pincode = (pincodeMap.get(req.email) as Map<string, string>).get(
      req.role!
    );

    if (pincode !== verifyPincodeSchema.pincode) {
      throw new BadRequestException("Invalid pincode.");
    }

    pincodeMap.delete(req.email);

    const action = req.action;
    if (action === "signup") {
      const user = await this._userRepository.signupUser(
        validateUserMap.get(req.email).get(req.role!)
      );

      res.json(user);
    } else if (action === "verifyEmail") {
      res.json(true);
    }
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
