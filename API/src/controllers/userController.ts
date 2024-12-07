import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { UserDto } from "../dtos/userDto";
import _ from "lodash";
import { uploadImages } from "../helper/helpers";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IFileService } from "../interfaces/services/IFileService";
import { IUserRepository } from "../interfaces/repositories/IUserRepository";
import { BadRequestException } from "../exceptions/badRequestException";
import { PORT } from "../secrets";

@injectable()
export class UserController {
  private _fileService: IFileService;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._fileService = fileService;
    this._userRepository = userRepository;
  }

  getCurrentUser(req: Request, res: Response) {
    const user = (req as any).user;

    const userDto = new UserDto();
    _.assign(userDto, _.pick(user, _.keys(userDto)));

    res.json(userDto);
  }

  async addPhoto(req: Request, res: Response) {
    const user = (req as any).user;

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
}
