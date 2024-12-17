import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { CommentRepository } from "../repositories/comment.repository";
import { CommentDto } from "./comment.dto";
import { FileDto } from "./file.dto";
import { UserDto } from "./user.dto";

export class PostDto {
  _id: string = "";
  publisherId: string = "";
  publisherUsername: string = "";
  publisherImageUrl?: string = "";
  title: string = "";
  description: string = "";
  category: "advertise" | "findPlayer" = "advertise";
  resources: string[] = [];
  createdAt: number = 0;
  comments: CommentDto[] = [];
  commentsCount: number = 0;
  likedUsers: UserDto[] = [];
  likesCount: number = 0;

  public static mapFrom(post: any): PostDto {
    return new PostDto(post);
  }

  private constructor(post: any) {
    this._id = post === null ? "" : post._id;
    this.publisherId = post === null ? "" : post.userId;
    this.title = post === null ? "" : post.title;
    this.description = post === null ? "" : post.description;
    this.category = post === null ? "" : post.category;
    this.resources =
      post === null ? [] : post.resources.map((r: FileDto) => r.url);
    this.likesCount = post === null ? 0 : post.likesCount;
    this.createdAt = post === null ? 0 : post.createdAt;
  }
}
