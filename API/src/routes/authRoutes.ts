import { Router } from "express";
import { Container } from "inversify";
import { IUserRepository } from "../interfaces/IUserRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { UserRepository } from "../repositories/userRepository";
import { AuthController } from "../controllers/authController";
import { errorHandler } from "../errorHandler";
import { IBcryptService } from "../interfaces/IBcryptService";
import { BcryptService } from "../services/bcryptService";
import { IJwtService } from "../interfaces/IJwtService";
import { JwtService } from "../services/jwtService";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IJwtService>(INTERFACE_TYPE.JwtService).to(JwtService);

container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.AuthController).to(AuthController);

const authRoutes: Router = Router();

const authController = container.get<AuthController>(
  INTERFACE_TYPE.AuthController
);

authRoutes.post(
  "/signup",
  errorHandler(authController.signup.bind(authController))
);

authRoutes.post(
  "/login/player",
  errorHandler(authController.loginAsPlayer.bind(authController))
);

export default authRoutes;
