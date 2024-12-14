import { FileDto } from "./file.dto";
import { UserDto } from "./user.dto";

export class PostDto {
  _id: string = "";
  publisherId: string = "";
  publisherImageUrl?: string = "";
  title: string = "";
  description: string = "";
  category: "advertise" | "findPlayer" = "advertise";
  resources: string[] = [];
}
