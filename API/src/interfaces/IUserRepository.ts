import { SignupDto } from "../schemas/auth";

export interface IUserRepository {
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
  signupUser(signupDto: SignupDto): Promise<any>;
}
