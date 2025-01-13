import { injectable } from "inversify";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import Post from "../models/post";
import { PagedList } from "../helper/pagedList";
import { PostParams } from "../params/post.params";
import { Aggregate } from "mongoose";
import { NewPostDto } from "../dtos/posts/newPost.dto";

@injectable()
export class PostRepository implements IPostRepository {
  async addLikedUser(post: any, userId: string): Promise<any> {
    post.likedUsers.push(userId);
    post.likesCount++;
    post.updatedAt = new Date();
    return await post.save();
  }

  async addPost(newPostDto: NewPostDto): Promise<any> {
    let post = new Post(newPostDto);
    post = await post.save();
    return post;
  }

  async getPostById(id: string): Promise<any> {
    return await Post.findById(id);
  }

  async getPosts(postParams: PostParams): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = Post.aggregate([]);

    if (postParams.userId) {
      aggregate = aggregate.match({ userId: postParams.userId });
    }

    if (postParams.category) {
      aggregate = aggregate.match({ category: postParams.category });
    }

    switch (postParams.sortBy) {
      case "createdAt":
        aggregate = aggregate.sort({
          createdAt: postParams.order === "asc" ? 1 : -1,
        });
      default:
        aggregate = aggregate.sort({
          createdAt: postParams.order === "asc" ? 1 : -1,
        });
    }

    const pipeline = aggregate.pipeline();
    let countAggregate = Post.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      postParams.pageNumber,
      postParams.pageSize
    );
  }

  async removeLikedUser(post: any, userId: string): Promise<any> {
    const index = post.likedUsers.indexOf(userId);
    post.likedUsers.splice(index, 1);
    post.likesCount--;
    post.updatedAt = new Date();
    return await post.save();
  }
}
