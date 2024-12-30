import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { UserDto } from "../dtos/user.dto";
import { addPaginationHeader, uploadImages } from "../helper/helpers";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IFileService } from "../interfaces/services/IFile.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { PORT } from "../secrets";
import { PostParams } from "../params/post.params";
import { PostParamsSchema } from "../schemas/posts/postParams.schema";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { PostDto } from "../dtos/post.dto";
import { UserParams } from "../params/user.params";
import { UserParamsSchema } from "../schemas/users/userParams.schema";
import { MessageRoomParams } from "../params/messageRoom.params";
import { IMessageRepository } from "../interfaces/repositories/IMessage.repository";
import { MessageRoomDto } from "../dtos/messageRoom.dto";
import { ChangePasswordSchema } from "../schemas/auth/changePassword.schema";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";

@injectable()
export class UserController {
  private _bcryptService: IBcryptService;
  private _fileService: IFileService;
  private _messageRepository: IMessageRepository;
  private _postRepository: IPostRepository;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.BcryptService) bcryptService: IBcryptService,
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.MessageRepository)
    messageRepository: IMessageRepository,
    @inject(INTERFACE_TYPE.PostRepository) postRepository: IPostRepository,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._bcryptService = bcryptService;
    this._fileService = fileService;
    this._messageRepository = messageRepository;
    this._postRepository = postRepository;
    this._userRepository = userRepository;
  }

  async addPhoto(req: Request, res: Response) {
    const user = req.user;

    // Delete old image (if exists)
    if (user.image) {
      await this._fileService.deleteFile(user.image.publicId);
    }

    // Upload photo
    const photos = await uploadImages(
      this._fileService,
      [req.file!],
      `users/${user.username}`
    );

    const photo = await this._userRepository.addPhoto(user._id, photos[0]);

    if (!photo) throw new BadRequestException("Problem adding photo.");

    res
      .status(201)
      .location(`https://localhost:${PORT}/api/users/me}`)
      .json({ url: photo.url });
  }

  getCurrentUser(req: Request, res: Response) {
    const user = req.user;

    const userDto = UserDto.mapFrom(user);

    res.json(userDto);
  }

  async getCurrentUserPosts(req: Request, res: Response) {
    const postParams: PostParams = PostParamsSchema.parse(req.query);
    postParams.userId = req.user._id;

    const posts = await this._postRepository.getPosts(postParams);

    addPaginationHeader(res, posts);

    const postDtos: PostDto[] = [];
    for (let post of posts) {
      const postDto = PostDto.mapFrom(post);

      const user = await this._userRepository.getUserById(post.userId);
      postDto.publisherUsername = user.username;
      if (user.imageUrl) {
        postDto.publisherImageUrl = user.imageUrl;
      }

      postDtos.push(postDto);
    }

    res.json(postDtos);
  }

  async getUsers(req: Request, res: Response) {
    const userParams: UserParams = UserParamsSchema.parse(req.query);
    userParams.currentUserId = req.user._id;

    const users = await this._userRepository.getUsers(userParams);
    const userDtos: UserDto[] = [];
    for (let user of users) {
      const userDto = UserDto.mapFrom(user);

      userDtos.push(userDto);
    }

    addPaginationHeader(res, users);

    res.json(userDtos);
  }

  async getCurrentUserMessageRooms(req: Request, res: Response) {
    const user = req.user;

    const messageRoomParams = new MessageRoomParams();
    messageRoomParams.userId = user._id.toString();

    const messageRooms = await this._messageRepository.getMessageRooms(
      messageRoomParams
    );

    addPaginationHeader(res, messageRooms);

    const messageRoomDtos: MessageRoomDto[] = [];
    for (let messageRoom of messageRooms) {
      const messageRoomDto = MessageRoomDto.mapFrom(messageRoom);

      messageRoomDtos.push(messageRoomDto);
    }

    res.json(messageRoomDtos);
  }

  async changePassword(req: Request, res: Response) {
    const user = req.user;
    const changePasswordDto = ChangePasswordSchema.parse(req.body);

    const isPasswordMatch = this._bcryptService.comparePassword(
      changePasswordDto.currentPassword,
      user.password
    );
    if (!isPasswordMatch) {
      throw new BadRequestException("Current password is incorrect.");
    }

    user.password = this._bcryptService.hashPassword(
      changePasswordDto.newPassword
    );
    user.updatedAt = Date.now();
    await user.save();

    res.status(204).send();
  }
}
