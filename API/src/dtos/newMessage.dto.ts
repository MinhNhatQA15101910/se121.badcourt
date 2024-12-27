import { FileDto } from "./file.dto";

export class NewMessageDto {
  recipientId: string = "";
  content: string = "";
  resources?: FileDto[] = [];
  senderId?: string;
  roomId?: string;
}
