import { injectable } from "inversify";
import { IPostRepository } from "../interfaces/repositories/IPostRepository";
import { NewPostDto } from "../dtos/newPostDto";
import Post from "../models/post";

@injectable()
export class PostRepository implements IPostRepository {
  async addPost(newPostDto: NewPostDto): Promise<any> {
    let post = new Post(newPostDto);
    post = await post.save();
    return post;
  }
}
