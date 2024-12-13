import { NewPostDto } from "../../dtos/newPostDto";
import { PagedList } from "../../helper/pagedList";
import { PostParams } from "../../params/postParams";

export interface IPostRepository {
  addPost(newPostDto: NewPostDto): Promise<any>;
  getPostById(id: string): Promise<any>;
  getPosts(postParams: PostParams): Promise<PagedList<any>>;
}
