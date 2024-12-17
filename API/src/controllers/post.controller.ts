import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { NewPostDto } from "../dtos/newPost.dto";
import { AddPostSchema } from "../schemas/post/addPost.schema";
import { IFileService } from "../interfaces/services/IFile.service";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { addPaginationHeader, uploadImages } from "../helper/helpers";
import { PostDto } from "../dtos/post.dto";
import { FileDto } from "../dtos/file.dto";
import { PORT } from "../secrets";
import { NotFoundException } from "../exceptions/notFound.exception";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { PostParamsSchema } from "../schemas/post/postParams.schema";
import { PostParams } from "../params/post.params";

@injectable()
export class PostController {
  private _fileService: IFileService;
  private _postRepository: IPostRepository;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.PostRepository)
    postRepository: IPostRepository,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._fileService = fileService;
    this._postRepository = postRepository;
    this._userRepository = userRepository;
  }

  async addPost(req: Request, res: Response) {
    const newPostDto: NewPostDto = AddPostSchema.parse(req.body);

    // Attach userId to newPostDto
    const user = req.user;
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
    const postDto = PostDto.mapFrom(post);
    postDto.publisherUsername = user.username;
    if (user.imageUrl) {
      postDto.publisherImageUrl = user.imageUrl;
    }

    res
      .status(201)
      .location(`https://localhost:${PORT}/api/posts/${post._id})}`)
      .json(postDto);
  }

  async getPost(req: Request, res: Response) {
    const postId = req.params.id;

    // Get post by id
    const post = await this._postRepository.getPostById(postId);
    if (!post) {
      throw new NotFoundException("Post not found!");
    }

    // Map to postDto
    const postDto = PostDto.mapFrom(post);
    postDto.resources = post.resources.map((r: FileDto) => r.url);

    const user = await this._userRepository.getUserById(post.userId);
    postDto.publisherUsername = user.username;
    if (user.imageUrl) {
      postDto.publisherImageUrl = user.imageUrl;
    }

    res.json(postDto);
  }

  async getPosts(req: Request, res: Response) {
    const postParams: PostParams = PostParamsSchema.parse(req.query);

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
}
