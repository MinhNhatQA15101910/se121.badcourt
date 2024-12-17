import { NewCommentDto } from "../../dtos/newComment.dto";

export interface ICommentRepository {
  getCommentsCount(postId: string): Promise<number>;
  getTop3CommentsForPost(postId: string): Promise<any[]>;
  addComment(newCommentDto: NewCommentDto): Promise<any>;
}
