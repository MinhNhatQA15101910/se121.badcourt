import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IFileService } from "../interfaces/services/IFile.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { MessageDto } from "../dtos/message.dto";
import { addPaginationHeader, uploadImages } from "../helper/helpers";
import { NewMessageToRoomSchema } from "../schemas/messages/newMessageToRoom.schema";
import { NewMessageToUserSchema } from "../schemas/messages/newMessageToUser.schema";
import { NewMessageDto } from "../dtos/newMessage.dto";
import { NewMessageRoomDto } from "../dtos/newMessageRoom.dto";
import { MessageParams } from "../params/message.params";
import { MessageParamsSchema } from "../schemas/messages/messageParams.schema";
import { PORT } from "../secrets";

@injectable()
export class MessageController {
  private _messageRepository: IMessageRepository;
  private _userRepository: IUserRepository;
  private _fileService: IFileService;

  constructor(
    @inject(INTERFACE_TYPE.MessageRepository)
    messageRepository: IMessageRepository,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository,
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService
  ) {
    this._messageRepository = messageRepository;
    this._userRepository = userRepository;
    this._fileService = fileService;
  }

  async sendMessageToUser(req: Request, res: Response) {
    const user = req.user;

    // Get message from body
    const newMessageDto: NewMessageDto = NewMessageToUserSchema.parse(req.body);

    // Get recipient user
    const recipient = await this._userRepository.getUserById(
      newMessageDto.recipientId!
    );
    if (!recipient) {
      throw new BadRequestException("Recipient user not found");
    }

    if (recipient._id.toString() === user._id.toString()) {
      throw new BadRequestException("Cannot send message to yourself");
    }

    // Check if the personal message room already exists
    let messageRoom = await this._messageRepository.getPersonalMessageRoom(
      user._id,
      recipient._id
    );
    let existed = false;
    if (messageRoom !== null) {
      newMessageDto.roomId = messageRoom._id;
      existed = true;
    } else {
      messageRoom = await this._messageRepository.createMessageRoom(
        new NewMessageRoomDto()
      );
      newMessageDto.roomId = messageRoom._id;
    }

    // Create message
    newMessageDto.senderId = user._id;
    const message = await this._messageRepository.createMessage(newMessageDto);

    // Upload resources
    const resources = await uploadImages(
      this._fileService,
      (req as any).files,
      `messages/${message._id}`
    );

    // Update message with resources
    message.resources = resources;

    message.createdAt = Date.now();
    message.updatedAt = Date.now();
    await message.save();

    // Update message room with message
    messageRoom.messages.push(message._id);

    // Update message room with users
    if (!existed) {
      messageRoom.users.push(user._id);
      messageRoom.users.push(recipient._id);
    }

    messageRoom.createdAt = Date.now();
    messageRoom.updatedAt = Date.now();
    await messageRoom.save();

    // Update user chat rooms
    if (!existed) {
      await this._userRepository.addChatRoom(user, messageRoom._id.toString());
      await this._userRepository.addChatRoom(
        recipient,
        messageRoom._id.toString()
      );
    }

    // Map to MessageDto
    const messageDto = MessageDto.mapFrom(message);

    // Add sender info
    messageDto.senderImageUrl = user.image ? user.image.url : "";

    return res
      .status(201)
      .location(
        `https://localhost:${PORT}/api/messages?roomId=${messageRoom._id.toString()})}`
      )
      .json(messageDto);
  }

  async sendMessageToRoom(req: Request, res: Response) {
    const user = req.user;

    // Get message from body
    const newMessageDto: NewMessageDto = NewMessageToRoomSchema.parse(req.body);

    // Get room
    const room = await this._messageRepository.getMessageRoomById(
      newMessageDto.roomId!
    );
    if (!room) {
      throw new BadRequestException("Room not found");
    }

    // Check if user is in the room
    if (!room.users.includes(user._id)) {
      throw new BadRequestException("User is not in the room");
    }

    // Create message
    newMessageDto.senderId = user._id;
    const message = await this._messageRepository.createMessage(newMessageDto);

    // Upload resources
    const resources = await uploadImages(
      this._fileService,
      (req as any).files,
      `messages/${message._id}`
    );

    // Update message with resources
    message.resources = resources;

    message.createdAt = Date.now();
    message.updatedAt = Date.now();
    await message.save();

    // Update message room with message
    room.messages.push(message._id);
    room.createdAt = Date.now();
    room.updatedAt = Date.now();
    await room.save();

    // Map to MessageDto
    const messageDto = MessageDto.mapFrom(message);

    // Add sender info
    messageDto.senderImageUrl = user.image ? user.image.url : "";

    return res
      .status(201)
      .location(
        `https://localhost:${PORT}/api/messages?roomId=${room._id.toString()})}`
      )
      .json(messageDto);
  }

  async getMessagesInRoom(req: Request, res: Response) {
    const user = req.user;

    // Get pagination params
    const messageParams: MessageParams = MessageParamsSchema.parse(req.query);

    // Get room
    const room = await this._messageRepository.getMessageRoomById(
      messageParams.roomId
    );
    if (!room) {
      throw new BadRequestException("Room not found");
    }

    // Check if user is in the room
    if (!room.users.includes(user._id)) {
      throw new BadRequestException("User is not in the room");
    }

    // Get messages
    const messages = await this._messageRepository.getMessagesInRoom(
      messageParams
    );

    // Add pagination header
    addPaginationHeader(res, messages);

    // Map to MessageDto
    const messageDtos = [];
    for (let message of messages) {
      const messageDto = MessageDto.mapFrom(message);
      messageDto.senderImageUrl = user.image ? user.image.url : "";
      messageDtos.push(messageDto);
    }

    res.json(messageDtos);
  }
}
