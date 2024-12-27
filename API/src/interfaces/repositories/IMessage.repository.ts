import { NewMessageDto } from "../../dtos/newMessage.dto";
import { NewMessageRoomDto } from "../../dtos/newMessageRoom.dto";
import { PagedList } from "../../helper/pagedList";
import { MessageRoomParams } from "../../params/messageRoom.params";

export interface IMessageRepository {
  createMessage(newMessageDto: NewMessageDto): Promise<any>;
  createMessageRoom(newMessageRoomDto: NewMessageRoomDto): Promise<any>;
  getMessageRoomById(roomId: string): Promise<any>;
  getMessageRooms(
    messageRoomParams: MessageRoomParams
  ): Promise<PagedList<any>>;
  getPersonalMessageRoom(user1Id: string, user2Id: string): Promise<any>;
}
