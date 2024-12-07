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

const container = new Container();

container.bind<IFileService>(INTERFACE_TYPE.FileService).to(FileService);

container
  .bind<IPostRepository>(INTERFACE_TYPE.PostRepository)
  .to(PostRepository);

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

export default postRoutes;
