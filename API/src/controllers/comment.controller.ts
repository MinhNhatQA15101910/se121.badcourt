import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { AddCommentSchema } from "../schemas/comments/addComment.schema";
import { NewCommentDto } from "../dtos/newComment.dto";
import { ICommentRepository } from "../interfaces/repositories/IComment.repository";
import { CommentDto } from "../dtos/comment.dto";
import { PORT } from "../secrets";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { NotFoundException } from "../exceptions/notFound.exception";
import { CommentParamsSchema } from "../schemas/comments/commentParams.schema";
import { CommentParams } from "../params/comment.params";
import { addPaginationHeader } from "../helper/helpers";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";

@injectable()
export class CommentController {
  private _commentRepository: ICommentRepository;
  private _postRepository: IPostRepository;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.CommentRepository)
    commentRepository: ICommentRepository,
    @inject(INTERFACE_TYPE.PostRepository) postRepository: IPostRepository,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._commentRepository = commentRepository;
    this._postRepository = postRepository;
    this._userRepository = userRepository;
  }

  async addComment(req: Request, res: Response) {
    const user = req.user;

    const newCommentDto: NewCommentDto = AddCommentSchema.parse(req.body);
    newCommentDto.userId = user._id;

    const post = await this._postRepository.getPostById(newCommentDto.postId);
    if (post === null || post === undefined) {
      throw new NotFoundException("Post not found.");
    }

    const comment = await this._commentRepository.addComment(newCommentDto);

    const commentDto = CommentDto.mapFrom(comment);
    commentDto.publisherUsername = user.username;
    commentDto.publisherImageUrl =
      user.image === undefined ? "" : user.image.url;

    res
      .status(201)
      .location(`https://localhost:${PORT}/api/posts/${newCommentDto.postId}`)
      .json(commentDto);
  }

  async getComments(req: Request, res: Response) {
    const commentParams: CommentParams = CommentParamsSchema.parse(req.query);

    const comments = await this._commentRepository.getComments(commentParams);

    addPaginationHeader(res, comments);

    const commentDtos: CommentDto[] = [];
    for (let comment of comments) {
      const commentDto = CommentDto.mapFrom(comment);

      // Add user info to commentDto
      const user = await this._userRepository.getUserById(comment.userId);
      commentDto.publisherUsername = user.username;
      commentDto.publisherImageUrl =
        user.image === undefined ? "" : user.image.url;

      commentDtos.push(commentDto);
    }

    res.json(commentDtos);
  }
}
