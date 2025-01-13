import { UserDto } from "../auth/user.dto";

export class MessageRoomDto {
  _id: string = "";
  roomName?: string;
  roomImageUrl?: string;
  users: UserDto[] = [];
  updatedAt: number = Date.now();

  public static mapFrom(messageRoom: any): MessageRoomDto {
    return new MessageRoomDto(messageRoom);
  }

  private constructor(messageRoom: any) {
    this._id = messageRoom === null ? "" : messageRoom._id;
    if (messageRoom && messageRoom.roomName) {
      this.roomName = messageRoom.roomName;
    }
    if (messageRoom && messageRoom.roomImage) {
      this.roomImageUrl = messageRoom.roomImage.url;
    }
    this.updatedAt = messageRoom === null ? Date.now() : messageRoom.updatedAt;
  }
}
