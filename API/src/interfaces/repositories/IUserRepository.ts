import { FileDto } from "../../dtos/fileDto";
import { SignupDto } from "../../schemas/auth/signup";

export interface IUserRepository {
  addPhoto(userId: string, fileDto: FileDto): Promise<FileDto | undefined>;
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
  getUserById(id: string): Promise<any>;
  signupUser(signupDto: SignupDto): Promise<any>;
}
