import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { UserDto } from "../dtos/user.dto";
import { addPaginationHeader, uploadImages } from "../helper/helpers";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IFileService } from "../interfaces/services/IFile.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { PORT } from "../secrets";
import { PostParamsSchema } from "../schemas/posts/postParams.schema";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { PostDto } from "../dtos/post.dto";
import { UserParams } from "../params/user.params";
import { UserParamsSchema } from "../schemas/users/userParams.schema";

@injectable()
export class UserController {
  private _fileService: IFileService;
  private _postRepository: IPostRepository;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.PostRepository) postRepository: IPostRepository,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._fileService = fileService;
    this._postRepository = postRepository;
    this._userRepository = userRepository;
  }

  async sendMessageToUser(req: Request, res: Response) {
    const user = req.user;
    const { userId } = req.params;

    if (user._id === userId) {
      throw new BadRequestException("You can't send a message to yourself");
    }

    const userToSend = await this._userRepository.getUserById(userId);

    
  }
}
