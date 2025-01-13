import { injectable } from "inversify";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { NewMessageRoomDto } from "../dtos/messages/newMessageRoom.dto";
import MessageRoom from "../models/messageRoom";
import Message from "../models/message";
import { PagedList } from "../helper/pagedList";
import { MessageRoomParams } from "../params/messageRoom.params";
import { Aggregate } from "mongoose";
import { NewMessageDto } from "../dtos/messages/newMessage.dto";
import { MessageParams } from "../params/message.params";

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
    const messageRoom = new MessageRoom({
      roomName: newMessageRoomDto.roomName,
      roomImage: newMessageRoomDto.roomImage,
      type: newMessageRoomDto.type,
      users: newMessageRoomDto.users,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });
    return await messageRoom.save();
  }

  async getLastMessage(roomId: string): Promise<any> {
    var message = await Message.findOne({ roomId })
      .sort({ createdAt: -1 })
      .exec();
    return message;
  }

  async getMessageRoomById(roomId: string): Promise<any> {
    return await MessageRoom.findById(roomId);
  }

  async getMessageRooms(
    messageRoomParams: MessageRoomParams
  ): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = MessageRoom.aggregate([]);

    if (messageRoomParams.userId) {
      aggregate = aggregate.match({ users: messageRoomParams.userId });
    }

    aggregate = aggregate.sort({ updatedAt: -1 });

    const pipeline = aggregate.pipeline();
    let countAggregate = MessageRoom.aggregate([
      ...pipeline,
      { $count: "count" },
    ]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      messageRoomParams.pageNumber,
      messageRoomParams.pageSize
    );
  }

  async getMessagesInRoom(
    messageParams: MessageParams
  ): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = Message.aggregate([]);

    if (messageParams.roomId) {
      aggregate = aggregate.match({ roomId: messageParams.roomId });
    }

    aggregate = aggregate.sort({ createdAt: -1 });

    const pipeline = aggregate.pipeline();
    let countAggregate = Message.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      messageParams.pageNumber,
      messageParams.pageSize
    );
  }

  async getPersonalMessageRoom(user1Id: string, user2Id: string): Promise<any> {
    return await MessageRoom.findOne({
      users: { $all: [user1Id, user2Id] },
      type: "personal",
    });
  }
}
