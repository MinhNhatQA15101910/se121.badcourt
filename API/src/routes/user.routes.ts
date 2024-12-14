import { Router } from "express";
import { Container } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { UserRepository } from "../repositories/user.repository";
import { UserController } from "../controllers/user.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { errorHandler } from "../errorHandler";
import { JwtService } from "../services/jwt.service";
import { IJwtService } from "../interfaces/services/IJwt.service";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { BcryptService } from "../services/bcrypt.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { upload } from "../middlewares/multer.middleware";
import { IFileService } from "../interfaces/services/IFile.service";
import { FileService } from "../services/file.service";

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
