import { Types } from "mongoose";

export class UserDto {
  _id: Types.ObjectId = new Types.ObjectId();
  username: string = "";
  email: string = "";
  imageUrl?: string = "";
  role: string = "";
  token?: string;
}
