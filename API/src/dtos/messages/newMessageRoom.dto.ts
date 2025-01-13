import { FileDto } from "../files/file.dto";

export class NewMessageRoomDto {
  roomName?: string;
  roomImage?: FileDto;
  type?: string;
  users: string[] = [];
}
