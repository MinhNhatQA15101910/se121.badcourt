import { Types } from "mongoose";
import { FileDto } from "./fileDto";

export class UserDto {
  _id: Types.ObjectId = new Types.ObjectId();
  username: string = "";
  email: string = "";
  image: FileDto | null = null;
  token: string = "";
}
