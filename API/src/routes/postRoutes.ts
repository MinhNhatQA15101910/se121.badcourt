import { Container } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware";
import { errorHandler } from "../errorHandler";
import { upload } from "../middlewares/multerMiddleware";
import { IFileService } from "../interfaces/services/IFileService";
import { FileService } from "../services/fileService";
import { IPostRepository } from "../interfaces/repositories/IPostRepository";
import { PostRepository } from "../repositories/postRepository";
import { PostController } from "../controllers/postController";
import { IUserRepository } from "../interfaces/repositories/IUserRepository";
import { UserRepository } from "../repositories/userRepository";
import { IBcryptService } from "../interfaces/services/IBcryptService";
import { BcryptService } from "../services/bcryptService";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IFileService>(INTERFACE_TYPE.FileService).to(FileService);

container
  .bind<IPostRepository>(INTERFACE_TYPE.PostRepository)
  .to(PostRepository);
container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.PostController).to(PostController);

const postRoutes: Router = Router();

const postController = container.get<PostController>(
  INTERFACE_TYPE.PostController
);

postRoutes.post(
  "/",
  [authMiddleware],
  upload.array("resources", 100),
  errorHandler(postController.addPost.bind(postController))
);

postRoutes.get(
  "/:id",
  errorHandler(postController.getPost.bind(postController))
);

postRoutes.get("/", errorHandler(postController.getPosts.bind(postController)));

export default postRoutes;
