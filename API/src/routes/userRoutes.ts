import { Router } from "express";
import { Container } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { UserRepository } from "../repositories/userRepository";
import { UserController } from "../controllers/userController";
import { authMiddleware } from "../middlewares/authMiddleware";
import { errorHandler } from "../errorHandler";
import { JwtService } from "../services/jwtService";
import { IJwtService } from "../interfaces/services/IJwtService";
import { IBcryptService } from "../interfaces/services/IBcryptService";
import { BcryptService } from "../services/bcryptService";
import { IUserRepository } from "../interfaces/repositories/IUserRepository";
import { upload } from "../middlewares/multerMiddleware";
import { IFileService } from "../interfaces/services/IFileService";
import { FileService } from "../services/fileService";

const container = new Container();

container.bind<IJwtService>(INTERFACE_TYPE.JwtService).to(JwtService);
container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IFileService>(INTERFACE_TYPE.FileService).to(FileService);

container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.UserController).to(UserController);

const userRoutes: Router = Router();

const userController = container.get<UserController>(
  INTERFACE_TYPE.UserController
);

userRoutes.get(
  "/me",
  [authMiddleware],
  errorHandler(userController.getCurrentUser.bind(userController))
);

userRoutes.post(
  "/add-photo",
  [authMiddleware],
  upload.single("file"),
  errorHandler(userController.addPhoto.bind(userController))
);

export default userRoutes;
