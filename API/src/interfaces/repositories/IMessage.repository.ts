import { NewMessageDto } from "../../dtos/newMessage.dto";
import { NewMessageRoomDto } from "../../dtos/newMessageRoom.dto";

export interface IMessageRepository {
  createMessage(newMessageDto: NewMessageDto): Promise<any>;
  createMessageRoom(newMessageRoomDto: NewMessageRoomDto): Promise<any>;
}
