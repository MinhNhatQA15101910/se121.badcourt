import { FileDto } from "../../dtos/file.dto";
import { SignupDto } from "../../dtos/signup.dto";
import { PagedList } from "../../helper/pagedList";
import { UserParams } from "../../params/user.params";

export interface IUserRepository {
  addChatRoom(user: any, chatRoomId: string): Promise<any>;
  addPhoto(userId: string, fileDto: FileDto): Promise<FileDto | undefined>;
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
  getUserById(id: string): Promise<any>;
  getUsers(userParams: UserParams): Promise<PagedList<any>>;
  likeComment(user: any, commentId: string): Promise<any>;
  likePost(user: any, postId: string): Promise<any>;
  signupUser(signupDto: SignupDto): Promise<any>;
  unlikeComment(user: any, commentId: string): Promise<any>;
  unlikePost(user: any, postId: string): Promise<any>;
}
