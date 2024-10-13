import { SignupDto } from "../../schemas/auth/signup";

export interface IUserRepository {
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
  getUserById(id: string): Promise<any>;
  signupUser(signupDto: SignupDto): Promise<any>;
}
