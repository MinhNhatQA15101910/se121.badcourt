import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { AddPostSchema } from "../schemas/posts/addPost.schema";
import { IFileService } from "../interfaces/services/IFile.service";
import { IPostRepository } from "../interfaces/repositories/IPost.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { addPaginationHeader, uploadImages } from "../helper/helpers";
import { PostDto } from "../dtos/posts/post.dto";
import { PORT } from "../secrets";
import { NotFoundException } from "../exceptions/notFound.exception";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { PostParamsSchema } from "../schemas/posts/postParams.schema";
import { PostParams } from "../params/post.params";
import { ICommentRepository } from "../interfaces/repositories/IComment.repository";
import { CommentDto } from "../dtos/comments/comment.dto";
import { UserDto } from "../dtos/auth/user.dto";
import { NewPostDto } from "../dtos/posts/newPost.dto";

@injectable()
export class PostController {
  private _fileService: IFileService;
  private _commentRepository: ICommentRepository;
  private _postRepository: IPostRepository;
  private _userRepository: IUserRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.CommentRepository)
    commentRepository: ICommentRepository,
    @inject(INTERFACE_TYPE.PostRepository)
    postRepository: IPostRepository,
    @inject(INTERFACE_TYPE.UserRepository) userRepository: IUserRepository
  ) {
    this._fileService = fileService;
    this._commentRepository = commentRepository;
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
    postDto.publisherImageUrl = user.image === undefined ? "" : user.image.url;

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

    // Add user info to postDto
    const user = await this._userRepository.getUserById(post.userId);
    postDto.publisherUsername = user.username;
    postDto.publisherImageUrl = user.image === undefined ? "" : user.image.url;

    // Add comments to postDto
    const comments = await this._commentRepository.getTop3CommentsForPost(
      postId
    );
    for (let comment of comments) {
      const commentDto = CommentDto.mapFrom(comment);

      const user = await this._userRepository.getUserById(comment.userId);
      commentDto.publisherUsername = user.username;
      commentDto.publisherImageUrl =
        user.image === undefined ? "" : user.image.url;

      postDto.comments.push(commentDto);
    }
    postDto.commentsCount = await this._commentRepository.getCommentsCount(
      postId
    );

    // Add liked users to postDto
    for (let userId of post.likedUsers) {
      const user = await this._userRepository.getUserById(userId);
      const userDto = UserDto.mapFrom(user);
      postDto.likedUsers.push(userDto);
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

      // Add user info to postDto
      const user = await this._userRepository.getUserById(post.userId);
      postDto.publisherUsername = user.username;
      postDto.publisherImageUrl =
        user.image === undefined ? "" : user.image.url;

      // Add comments to postDto
      const comments = await this._commentRepository.getTop3CommentsForPost(
        post._id
      );
      for (let comment of comments) {
        const commentDto = CommentDto.mapFrom(comment);

        const user = await this._userRepository.getUserById(comment.userId);
        commentDto.publisherUsername = user.username;
        commentDto.publisherImageUrl =
          user.image === undefined ? "" : user.image.url;

        postDto.comments.push(commentDto);
      }
      postDto.commentsCount = await this._commentRepository.getCommentsCount(
        post._id
      );

      // Add liked users to postDto
      for (let userId of post.likedUsers) {
        const user = await this._userRepository.getUserById(userId);
        const userDto = UserDto.mapFrom(user);
        postDto.likedUsers.push(userDto);
      }

      postDtos.push(postDto);
    }

    res.json(postDtos);
  }

  async toggleLike(req: Request, res: Response) {
    const user = req.user;

    const postId = req.params.id;

    const post = await this._postRepository.getPostById(postId);
    if (!post) {
      throw new NotFoundException("Post not found!");
    }

    const likedUsers = post.likedUsers;
    if (likedUsers.includes(user._id)) {
      console.log("Unliking");
      const updatedPost = await this._postRepository.removeLikedUser(
        post,
        user._id
      );
      const updatedUser = await this._userRepository.unlikePost(user, post._id);
      console.log(updatedPost, updatedUser);
    } else {
      console.log("Liking");
      const updatedPost = await this._postRepository.addLikedUser(
        post,
        user._id
      );
      const updatedUser = await this._userRepository.likePost(user, post._id);
      console.log(updatedPost, updatedUser);
    }

    res.json();
  }
}
