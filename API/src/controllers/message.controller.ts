import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IFileService } from "../interfaces/services/IFile.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { NewMessageSchema } from "../schemas/messages/newMessage.schema";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { NewMessageRoomDto } from "../dtos/newMessageRoom.dto";
import { MessageDto } from "../dtos/message.dto";
import { NewMessageDto } from "../dtos/newMessage.dto";
import { uploadImages } from "../helper/helpers";

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

  async sendMessageFromFacilityToUser(req: Request, res: Response) {
    const facility = req.facility;

    // Get message from body
    const newMessageDto: NewMessageDto = NewMessageSchema.parse(req.body);

    // Get recipient user
    const recipient = await this._userRepository.getUserById(
      newMessageDto.recipientId
    );
    if (!recipient) {
      throw new BadRequestException("Recipient user not found");
    }

    if (recipient._id.toString() === facility.userId.toString()) {
      throw new BadRequestException("Cannot send message to yourself");
    }

    // Check if the personal message room already exists
    let messageRoom = await this._messageRepository.getPersonalMessageRoom(
      facility._id,
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
    newMessageDto.senderId = facility._id;
    const message = await this._messageRepository.createMessage(newMessageDto);

    // Upload resources
    const resources = await uploadImages(
      this._fileService,
      (req as any).files,
      `messages/${message._id}`
    );

    // Update message with resources
    message.resources = resources;
    
    message.updatedAt = Date.now();
    await message.save();

    // Update message room with message
    messageRoom.messages.push(message._id);

    // Update message room with users
    if (!existed) {
      messageRoom.users.push(facility._id);
      messageRoom.users.push(recipient._id);
    }

    messageRoom.updatedAt = Date.now();
    await messageRoom.save();

    // Map to MessageDto
    const messageDto = MessageDto.mapFrom(message);

    // Add sender info
    messageDto.senderId = facility._id;
    messageDto.senderImageUrl = facility.facilityImages[0].url;

    return res.status(201).json(messageDto);
  }
}
