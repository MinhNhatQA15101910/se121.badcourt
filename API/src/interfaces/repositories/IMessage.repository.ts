import { NewMessageDto } from "../../dtos/messages/newMessage.dto";
import { NewMessageRoomDto } from "../../dtos/messages/newMessageRoom.dto";
import { PagedList } from "../../helper/pagedList";
import { MessageParams } from "../../params/message.params";
import { MessageRoomParams } from "../../params/messageRoom.params";

export interface IMessageRepository {
  createMessage(newMessageDto: NewMessageDto): Promise<any>;
  createMessageRoom(newMessageRoomDto: NewMessageRoomDto): Promise<any>;
  getLastMessage(roomId: string): Promise<any>;
  getMessageRoomById(roomId: string): Promise<any>;
  getMessagesInRoom(messageParams: MessageParams): Promise<PagedList<any>>;
  getMessageRooms(
    messageRoomParams: MessageRoomParams
  ): Promise<PagedList<any>>;
  getPersonalMessageRoom(user1Id: string, user2Id: string): Promise<any>;
}
