import { NewCommentDto } from "../../dtos/newComment.dto";

export interface ICommentRepository {
  getTop3CommentsForPost(postId: string): Promise<any[]>;
  addComment(newCommentDto: NewCommentDto): Promise<any>;
}
