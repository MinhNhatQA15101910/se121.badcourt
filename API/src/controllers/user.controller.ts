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
import { PostParamsSchema } from "../schemas/post/postParams.schema";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { PostDto } from "../dtos/post.dto";

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

  getCurrentUser(req: Request, res: Response) {
    const user = req.user;

    const userDto = UserDto.mapFrom(user);

    res.json(userDto);
  }

  async getCurrentUserPosts(req: Request, res: Response) {
    const postParams: PostParams = PostParamsSchema.parse(req.query);
    postParams.userId = req.user._id;
    console.log(postParams);

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
}
