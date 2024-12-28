import { FileDto } from "./file.dto";

export class NewMessageRoomDto {
  roomName?: string;
  roomImage?: FileDto;
  type?: string = "personal";
  users: string[] = [];
}
