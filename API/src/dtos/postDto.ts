import { FileDto } from "./fileDto";
import { UserDto } from "./userDto";

export class PostDto {
  _id: string = "";
  publisherId: string = "";
  publisherImageUrl?: string = "";
  title: string = "";
  description: string = "";
  category: "advertise" | "findPlayer" = "advertise";
  resources: string[] = [];
}
