import { NewCommentDto } from "../../dtos/newComment.dto";

export interface ICommentRepository {
  addComment(newCommentDto: NewCommentDto): Promise<any>;
}
