import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IFileService } from "../interfaces/services/IFile.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { MessageDto } from "../dtos/messages/message.dto";
import { addPaginationHeader, uploadImages } from "../helper/helpers";
import { NewMessageToRoomSchema } from "../schemas/messages/newMessageToRoom.schema";
import { NewMessageDto } from "../dtos/messages/newMessage.dto";
import { NewMessageRoomDto } from "../dtos/messages/newMessageRoom.dto";
import { MessageParams } from "../params/message.params";
import { MessageParamsSchema } from "../schemas/messages/messageParams.schema";
import { PORT } from "../secrets";
import { NewMessageRoomSchema } from "../schemas/messages/newMessageRoom.schema";
import { MessageRoomDto } from "../dtos/messages/messageRoom.dto";
import { NotFoundException } from "../exceptions/notFound.exception";
import { io } from "..";
import { UserDto } from "../dtos/auth/user.dto";

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

  async sendMessageToRoom(req: Request, res: Response) {
    const user = req.user;

    // Get message from body
    const newMessageDto: NewMessageDto = NewMessageToRoomSchema.parse(req.body);
    console.log(newMessageDto);

    // Check if the message have either content or resources
    if (!newMessageDto.content && !(req as any).files) {
      throw new BadRequestException("Message must have content or resources");
    }

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
    if ((req as any).files) {
      const resources = await uploadImages(
        this._fileService,
        (req as any).files,
        `messages/${message._id}`
      );

      // Update message with resources
      message.resources = resources;
    }

    message.createdAt = Date.now();
    message.updatedAt = Date.now();
    await message.save();

    // Map to MessageDto
    const messageDto = MessageDto.mapFrom(message);

    // Add sender info
    messageDto.senderImageUrl = user.image ? user.image.url : "";

    // Emit message to room
    console.log(room._id.toString(), messageDto);
    io.to(room._id.toString()).emit("newMessage", messageDto);

    // Emit message room to room
    const messageRoomDto = MessageRoomDto.mapFrom(room);
    messageRoomDto.lastMessage = messageDto;
    io.to(room._id.toString()).emit("messageRoom", messageRoomDto);

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

  async createMessageRoom(req: Request, res: Response) {
    if (typeof req.body.users === "string") {
      req.body.users = [req.body.users];
    }

    const currUser = req.user;

    // Get message room from body
    const newMessageRoomDto: NewMessageRoomDto = NewMessageRoomSchema.parse(
      req.body
    );

    // Check existence of users
    for (let userId of newMessageRoomDto.users) {
      const user = await this._userRepository.getUserById(userId);
      if (!user) {
        throw new BadRequestException("User not found");
      }
    }

    // Add current user to the room
    if (!newMessageRoomDto.users.includes(currUser._id.toString())) {
      newMessageRoomDto.users.push(currUser._id.toString());
    }

    // Check amount of users
    if (newMessageRoomDto.users.length === 2) {
      const existingRoom = await this._messageRepository.getPersonalMessageRoom(
        newMessageRoomDto.users[0],
        newMessageRoomDto.users[1]
      );
      if (existingRoom) {
        throw new BadRequestException("Personal room already exists");
      }

      newMessageRoomDto.type = "personal";
    } else {
      newMessageRoomDto.type = "group";
    }

    // Create room
    let messageRoom = await this._messageRepository.createMessageRoom(
      newMessageRoomDto
    );

    // Upload room image
    if ((req as any).file) {
      const roomImages = await uploadImages(
        this._fileService,
        [(req as any).file],
        `message_rooms/${messageRoom._id}`
      );

      messageRoom.roomImage = roomImages[0];
    }

    // Update room
    messageRoom.updatedAt = Date.now();
    messageRoom = await messageRoom.save();

    // Update user chat rooms
    for (let userId of newMessageRoomDto.users) {
      const user = await this._userRepository.getUserById(userId);

      user.chatRooms.push(messageRoom._id.toString());

      user.updatedAt = Date.now();
      await user.save();

      // Invoke enter room
      io.to(userId).emit("invokeEnterRoom", messageRoom._id.toString());
    }

    // Map to MessageRoomDto
    const messageRoomDto = MessageRoomDto.mapFrom(messageRoom);

    return res
      .status(201)
      .location(
        `https://localhost:${PORT}/api/messages?roomId=${messageRoom._id.toString()}`
      )
      .json(messageRoomDto);
  }

  async getPersonalMessageRoom(req: Request, res: Response) {
    const user = req.user;
    const userId = req.params.userId;

    // Check existence of user
    const recipient = await this._userRepository.getUserById(userId);
    if (!recipient) {
      throw new NotFoundException("User not found");
    }

    // Get personal message room
    const messageRoom = await this._messageRepository.getPersonalMessageRoom(
      user._id.toString(),
      userId
    );
    if (!messageRoom) {
      throw new NotFoundException("Personal message room not found");
    }

    // Map to MessageRoomDto
    const messageRoomDto = MessageRoomDto.mapFrom(messageRoom);
    messageRoomDto.lastMessage = await this._messageRepository.getLastMessage(
      messageRoom._id.toString()
    );
    for (let userId of messageRoom.users) {
      const user = await this._userRepository.getUserById(userId);
      messageRoomDto.users.push(UserDto.mapFrom(user));
    }

    res.json(messageRoomDto);
  }
}
