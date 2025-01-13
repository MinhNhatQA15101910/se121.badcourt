import { NewCommentDto } from "../../dtos/comments/newComment.dto";
import { PagedList } from "../../helper/pagedList";
import { CommentParams } from "../../params/comment.params";

export interface ICommentRepository {
  addComment(newCommentDto: NewCommentDto): Promise<any>;
  addLikedUser(comment: any, userId: string): Promise<any>;
  getCommentById(commentId: string): Promise<any>;
  getComments(commentParams: CommentParams): Promise<PagedList<any>>;
  getCommentsCount(postId: string): Promise<number>;
  getTop3CommentsForPost(postId: string): Promise<any[]>;
  removeLikedUser(comment: any, userId: string): Promise<any>;
}
