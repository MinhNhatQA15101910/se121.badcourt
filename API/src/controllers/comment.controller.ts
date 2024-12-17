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

@injectable()
export class CommentController {
  private _commentRepository: ICommentRepository;
  private _postRepository: IPostRepository;

  constructor(
    @inject(INTERFACE_TYPE.CommentRepository)
    commentRepository: ICommentRepository,
    @inject(INTERFACE_TYPE.PostRepository) postRepository: IPostRepository
  ) {
    this._commentRepository = commentRepository;
    this._postRepository = postRepository;
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
}
