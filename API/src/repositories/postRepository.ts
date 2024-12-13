import { injectable } from "inversify";
import { IPostRepository } from "../interfaces/repositories/IPostRepository";
import { NewPostDto } from "../dtos/newPostDto";
import Post from "../models/post";
import { PagedList } from "../helper/pagedList";
import { PostParams } from "../params/postParams";
import { Aggregate } from "mongoose";

@injectable()
export class PostRepository implements IPostRepository {
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
}
