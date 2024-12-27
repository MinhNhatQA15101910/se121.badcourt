import { Container } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Router } from "express";
import { errorHandler } from "../errorHandler";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { UserRepository } from "../repositories/user.repository";
import { IFileService } from "../interfaces/services/IFile.service";
import { FileService } from "../services/file.service";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { MessageRepository } from "../repositories/message.repository";
import { MessageController } from "../controllers/message.controller";
import { facilityMiddleware } from "../middlewares/facility.middleware";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { BcryptService } from "../services/bcrypt.service";
import { upload } from "../middlewares/multer.middleware";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IFileService>(INTERFACE_TYPE.FileService).to(FileService);

container
  .bind<IMessageRepository>(INTERFACE_TYPE.MessageRepository)
  .to(MessageRepository);
container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.MessageController).to(MessageController);

const messageRoutes: Router = Router();

const messageController = container.get<MessageController>(
  INTERFACE_TYPE.MessageController
);

messageRoutes.post(
  "/facility/send-to-user",
  [facilityMiddleware],
  upload.array("resources", 100),
  errorHandler(
    messageController.sendMessageFromFacilityToUser.bind(messageController)
  )
);

export default messageRoutes;
