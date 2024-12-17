import { NewCommentDto } from "../../dtos/newComment.dto";
import { PagedList } from "../../helper/pagedList";
import { CommentParams } from "../../params/comment.params";

export interface ICommentRepository {
  getComments(commentParams: CommentParams): Promise<PagedList<any>>;
  getCommentsCount(postId: string): Promise<number>;
  getTop3CommentsForPost(postId: string): Promise<any[]>;
  addComment(newCommentDto: NewCommentDto): Promise<any>;
}
