import { Container } from "inversify";
import { ICommentRepository } from "../interfaces/repositories/IComment.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { CommentRepository } from "../repositories/comment.repository";
import { CommentController } from "../controllers/comment.controller";
import { Router } from "express";
import { errorHandler } from "../errorHandler";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { PostRepository } from "../repositories/post.repository";
import { authMiddleware } from "../middlewares/auth.middleware";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { UserRepository } from "../repositories/user.repository";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { BcryptService } from "../services/bcrypt.service";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);

container
  .bind<ICommentRepository>(INTERFACE_TYPE.CommentRepository)
  .to(CommentRepository);
container
  .bind<IPostRepository>(INTERFACE_TYPE.PostRepository)
  .to(PostRepository);
container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.CommentController).to(CommentController);

const commentRoutes: Router = Router();

const commentController = container.get<CommentController>(
  INTERFACE_TYPE.CommentController
);

commentRoutes.post(
  "/",
  [authMiddleware],
  errorHandler(commentController.addComment.bind(commentController))
);

commentRoutes.get(
  "/",
  errorHandler(commentController.getComments.bind(commentController))
);

export default commentRoutes;
