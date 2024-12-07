import { NewPostDto } from "../../dtos/newPostDto";

export interface IPostRepository {
  addPost(newPostDto: NewPostDto): Promise<any>;
}
