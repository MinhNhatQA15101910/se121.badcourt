import { FileDto } from "../../dtos/file.dto";
import { PagedList } from "../../helper/pagedList";
import { UserParams } from "../../params/user.params";
import { SignupDto } from "../../schemas/auth/signup.schema";

export interface IUserRepository {
  addPhoto(userId: string, fileDto: FileDto): Promise<FileDto | undefined>;
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
  getUserById(id: string): Promise<any>;
  getUsers(userParams: UserParams): Promise<PagedList<any>>;
  likePost(user: any, postId: string): Promise<any>;
  signupUser(signupDto: SignupDto): Promise<any>;
  unlikePost(user: any, postId: string): Promise<any>;
}
