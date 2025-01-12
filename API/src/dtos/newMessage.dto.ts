import { FileDto } from "./file.dto";

export class NewMessageDto {
  roomId?: string;
  content?: string = "";
  resources?: FileDto[] = [];
  senderId?: string;
  recipientId?: string;
}
