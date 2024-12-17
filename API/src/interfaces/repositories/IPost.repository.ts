import { NewPostDto } from "../../dtos/newPost.dto";
import { PagedList } from "../../helper/pagedList";
import { PostParams } from "../../params/post.params";

export interface IPostRepository {
  addLikedUser(post: any, userId: string): Promise<any>;
  addPost(newPostDto: NewPostDto): Promise<any>;
  getPostById(id: string): Promise<any>;
  getPosts(postParams: PostParams): Promise<PagedList<any>>;
  removeLikedUser(post: any, userId: string): Promise<any>;
}
