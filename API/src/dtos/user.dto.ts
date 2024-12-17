import { Types } from "mongoose";

export class UserDto {
  _id: Types.ObjectId = new Types.ObjectId();
  username: string = "";
  email: string = "";
  imageUrl?: string = "";
  role: string = "";
  createAt: Number = 0;
  token?: string;

  public static mapFrom(user: any): UserDto {
    return new UserDto(user);
  }

  private constructor(user?: any) {
    this._id = user === null ? "" : user._id;
    this.username = user === null ? "" : user.username;
    this.email = user === null ? "" : user.email;
    if (user != null && user.image) {
      this.imageUrl = user.image.url;
    }
    this.role = user === null ? "" : user.role;
    this.createAt = user === null ? 0 : user.createAt;
  }
}
