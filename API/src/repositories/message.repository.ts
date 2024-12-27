import { injectable } from "inversify";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { NewMessageRoomDto } from "../dtos/newMessageRoom.dto";
import MessageRoom from "../models/messageRoom";
import { NewMessageDto } from "../dtos/newMessage.dto";
import Message from "../models/message";

@injectable()
export class MessageRepository implements IMessageRepository {
  async createMessage(newMessageDto: NewMessageDto): Promise<any> {
    let message = new Message({
      content: newMessageDto.content,
      resources: newMessageDto.resources,
      senderId: newMessageDto.senderId,
      roomId: newMessageDto.roomId,
    });
    message = await message.save();
    return message;
  }

  async createMessageRoom(newMessageRoomDto: NewMessageRoomDto): Promise<any> {
    let messageRoom = new MessageRoom({
      roomName: newMessageRoomDto.roomName,
      roomImage: newMessageRoomDto.roomImage,
    });
    messageRoom = await messageRoom.save();
    return messageRoom;
  }

  getPersonalMessageRoom(user1Id: string, user2Id: string): Promise<any> {
    return MessageRoom.findOne({ users: [user1Id, user2Id], type: "personal" });
  }
}
