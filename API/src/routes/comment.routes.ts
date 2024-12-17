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

const container = new Container();

container
  .bind<ICommentRepository>(INTERFACE_TYPE.CommentRepository)
  .to(CommentRepository);
container
  .bind<IPostRepository>(INTERFACE_TYPE.PostRepository)
  .to(PostRepository);

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

export default commentRoutes;
