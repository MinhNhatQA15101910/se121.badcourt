import { injectable } from "inversify";
import { ICommentRepository } from "../interfaces/repositories/IComment.repository";
import { NewCommentDto } from "../dtos/newComment.dto";
import Comment from "../models/comment";

@injectable()
export class CommentRepository implements ICommentRepository {
  async addComment(newCommentDto: NewCommentDto): Promise<any> {
    let comment = new Comment(newCommentDto);
    comment = await comment.save();
    return comment;
  }
}
