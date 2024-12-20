import { inject, injectable } from "inversify";
import { SignupDto } from "../schemas/auth/signup.schema";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import User from "../models/user";
import { FileDto } from "../dtos/file.dto";
import { PagedList } from "../helper/pagedList";
import { UserParams } from "../params/user.params";
import { Aggregate } from "mongoose";

@injectable()
export class UserRepository implements IUserRepository {
  private _bcryptService: IBcryptService;

  constructor(
    @inject(INTERFACE_TYPE.BcryptService) bcryptService: IBcryptService
  ) {
    this._bcryptService = bcryptService;
  }

  async addPhoto(
    userId: string,
    fileDto: FileDto
  ): Promise<FileDto | undefined> {
    let user = await User.findById(userId);

    if (!user) {
      return undefined;
    }

    user.image = fileDto;
    user = await user.save();

    return fileDto;
  }

  async getUserByEmail(email: string): Promise<any> {
    const user = await User.findOne({ email });
    return user;
  }

  async getUserByEmailAndRole(email: string, role: string): Promise<any> {
    const user = await User.findOne({ email, role });
    return user;
  }

  async getUserById(id: string): Promise<any> {
    return await User.findById(id);
  }

  async getUsers(userParams: UserParams): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = User.aggregate([]);

    aggregate = aggregate.match({ _id: { $ne: userParams.currentUserId } });

    if (userParams.username) {
      aggregate = aggregate.match({
        username: { $regex: userParams.username, $options: "i" },
      });
    }

    if (userParams.email) {
      aggregate = aggregate.match({ email: userParams.email });
    }

    if (userParams.role) {
      aggregate = aggregate.match({ role: userParams.role });
    }

    switch (userParams.sortBy) {
      case "email":
        aggregate = aggregate.sort({
          email: userParams.order === "asc" ? 1 : -1,
        });
      case "role":
        aggregate = aggregate.sort({
          role: userParams.order === "asc" ? 1 : -1,
        });
      case "createdAt":
        aggregate = aggregate.sort({
          createdAt: userParams.order === "asc" ? 1 : -1,
        });
      case "username":
      default:
        aggregate = aggregate.sort({
          username: userParams.order === "asc" ? 1 : -1,
        });
    }

    const pipeline = aggregate.pipeline();
    let countAggregate = User.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      userParams.pageNumber,
      userParams.pageSize
    );
  }

  async likeComment(user: any, commentId: string): Promise<any> {
    user.likedComments.push(commentId);
    user.updatedAt = new Date();
    return await user.save();
  }

  async likePost(user: any, postId: string): Promise<any> {
    user.likedPosts.push(postId);
    user.updatedAt = new Date();
    return await user.save();
  }

  async signupUser(signupDto: SignupDto): Promise<any> {
    let user = await User.create({
      username: signupDto.username,
      email: signupDto.email,
      imageUrl: signupDto.imageUrl,
      password: this._bcryptService.hashPassword(signupDto.password),
      role: signupDto.role,
    });
    user = await user.save();
    return user;
  }

  async unlikeComment(user: any, commentId: string): Promise<any> {
    const index = user.likedComments.indexOf(commentId);
    user.likedComments.splice(index, 1);
    user.updatedAt = new Date();
    return await user.save();
  }

  async unlikePost(user: any, postId: string): Promise<any> {
    const index = user.likedPosts.indexOf(postId);
    user.likedPosts.splice(index, 1);
    user.updatedAt = new Date();
    return await user.save();
  }
}
