export interface IMessageRepository {
  createMessageRoom(messageRoomDto: MessageRoomDto): Promise<any>;
}
