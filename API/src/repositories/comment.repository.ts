import { injectable } from "inversify";
import { ICommentRepository } from "../interfaces/repositories/IComment.repository";
import { NewCommentDto } from "../dtos/newComment.dto";
import Comment from "../models/comment";
import { PagedList } from "../helper/pagedList";
import { CommentParams } from "../params/comment.params";
import { Aggregate } from "mongoose";

@injectable()
export class CommentRepository implements ICommentRepository {
  async addComment(newCommentDto: NewCommentDto): Promise<any> {
    let comment = new Comment(newCommentDto);
    comment = await comment.save();
    return comment;
  }

  async addLikedUser(comment: any, userId: string): Promise<any> {
    comment.likedUsers.push(userId);
    comment.likesCount++;
    comment.updatedAt = new Date();
    return await comment.save();
  }

  async getCommentById(commentId: string): Promise<any> {
    return await Comment.findById(commentId);
  }

  async getComments(commentParams: CommentParams): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = Comment.aggregate([]);

    if (commentParams.postId) {
      aggregate = aggregate.match({ postId: commentParams.postId });
    }

    switch (commentParams.sortBy) {
      case "createdAt":
      default:
        aggregate = aggregate.sort({
          createdAt: commentParams.order === "asc" ? 1 : -1,
        });
    }

    const pipeline = aggregate.pipeline();
    let countAggregate = Comment.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      commentParams.pageNumber,
      commentParams.pageSize
    );
  }

  async getCommentsCount(postId: string): Promise<number> {
    return await Comment.countDocuments({ postId });
  }

  async getTop3CommentsForPost(postId: string): Promise<any[]> {
    const comments = await Comment.find({ postId })
      .sort({ updated: -1 })
      .limit(3);
    return comments;
  }

  async removeLikedUser(comment: any, userId: string): Promise<any> {
    const index = comment.likedUsers.indexOf(userId);
    comment.likedUsers.splice(index, 1);
    comment.likesCount--;
    comment.updatedAt = new Date();
    return await comment.save();
  }
}
