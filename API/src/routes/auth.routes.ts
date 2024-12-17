import { Router } from "express";
import { Container } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { UserRepository } from "../repositories/user.repository";
import { AuthController } from "../controllers/auth.controller";
import { errorHandler } from "../errorHandler";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { BcryptService } from "../services/bcrypt.service";
import { IJwtService } from "../interfaces/services/IJwt.service";
import { JwtService } from "../services/jwt.service";
import { IMailService } from "../interfaces/services/IMail.service";
import { MailService } from "../services/mail.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { userEmailMiddleware } from "../middlewares/userEmail.middleware";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IJwtService>(INTERFACE_TYPE.JwtService).to(JwtService);
container.bind<IMailService>(INTERFACE_TYPE.MailService).to(MailService);

container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.AuthController).to(AuthController);

const authRoutes: Router = Router();

const authController = container.get<AuthController>(
  INTERFACE_TYPE.AuthController
);

authRoutes.post(
  "/validate-signup",
  errorHandler(authController.validateSignup.bind(authController))
);

authRoutes.post(
  "/signup",
  errorHandler(authController.signup.bind(authController))
);

authRoutes.post(
  "/login",
  errorHandler(authController.login.bind(authController))
);

authRoutes.post(
  "/login/google",
  errorHandler(authController.loginWithGoogle.bind(authController))
);

authRoutes.post(
  "/email-exists",
  errorHandler(authController.validateEmail.bind(authController))
);

authRoutes.post(
  "/send-verify-email",
  [userEmailMiddleware],
  errorHandler(authController.sendVerifyEmail.bind(authController))
);

authRoutes.patch(
  "/change-password",
  errorHandler(authController.changePassword.bind(authController))
);

authRoutes.post(
  "/token-is-valid",
  errorHandler(authController.validateToken.bind(authController))
);

export default authRoutes;
