import { Container } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware";
import { errorHandler } from "../errorHandler";
import { upload } from "../middlewares/multer.middleware";
import { IFileService } from "../interfaces/services/IFile.service";
import { FileService } from "../services/file.service";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { PostRepository } from "../repositories/post.repository";
import { PostController } from "../controllers/post.controller";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { UserRepository } from "../repositories/user.repository";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { BcryptService } from "../services/bcrypt.service";
import { ICommentRepository } from "../interfaces/repositories/IComment.repository";
import { CommentRepository } from "../repositories/comment.repository";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IFileService>(INTERFACE_TYPE.FileService).to(FileService);

container
  .bind<ICommentRepository>(INTERFACE_TYPE.CommentRepository)
  .to(CommentRepository);
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
