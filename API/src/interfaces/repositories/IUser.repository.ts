import { FileDto } from "../../dtos/file.dto";
import { SignupDto } from "../../schemas/auth/signup.schema";

export interface IUserRepository {
  addPhoto(userId: string, fileDto: FileDto): Promise<FileDto | undefined>;
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
  getUserById(id: string): Promise<any>;
  signupUser(signupDto: SignupDto): Promise<any>;
}
