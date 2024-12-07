import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { NewPostDto } from "../dtos/newPostDto";
import { AddPostSchema } from "../schemas/post/addPost";
import { IFileService } from "../interfaces/services/IFileService";
import { IPostRepository } from "../interfaces/repositories/IPostRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { uploadImages } from "../helper/helpers";
import _ from "lodash";
import { PostDto } from "../dtos/postDto";
import { FileDto } from "../dtos/fileDto";
import { PORT } from "../secrets";

@injectable()
export class PostController {
  private _fileService: IFileService;
  private _postRepository: IPostRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.PostRepository)
    postRepository: IPostRepository
  ) {
    this._fileService = fileService;
    this._postRepository = postRepository;
  }

  async addPost(req: Request, res: Response) {
    const newPostDto: NewPostDto = AddPostSchema.parse(req.body);

    // Attach userId to newPostDto
    const user = (req as any).user;
    newPostDto.userId = user._id;

    // Upload resources
    const resources = await uploadImages(
      this._fileService,
      (req as any).files,
      `posts/${user.username}/${newPostDto.title}`
    );
    newPostDto.resources = resources;

    // Save post to database
    const post = await this._postRepository.addPost(newPostDto);

    // Map to postDto
    const postDto = new PostDto();
    _.assign(postDto, _.pick(post, _.keys(postDto)));
    postDto.publisherId = post.userId;
    if (user.imageUrl) {
      postDto.publisherImageUrl = user.imageUrl;
    }
    postDto.resources = post.resources.map((r: FileDto) => r.url);

    res
      .status(201)
      .location(`https://localhost:${PORT}/api/posts/${post._id})}`)
      .json(postDto);
  }
}
