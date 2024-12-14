import { FileDto } from "./file.dto";

export class PostDto {
  _id: string = "";
  publisherId: string = "";
  publisherUsername: string = "";
  publisherImageUrl?: string = "";
  title: string = "";
  description: string = "";
  category: "advertise" | "findPlayer" = "advertise";
  resources: string[] = [];

  public static mapFrom(post: any): PostDto {
    return new PostDto(post);
  }

  private constructor(post?: any) {
    this._id = post === null ? "" : post._id;
    this.publisherId = post === null ? "" : post.userId;
    this.title = post === null ? "" : post.title;
    this.description = post === null ? "" : post.description;
    this.category = post === null ? "" : post.category;
    this.resources =
      post === null ? [] : post.resources.map((r: FileDto) => r.url);
  }
}
