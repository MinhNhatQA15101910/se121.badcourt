export interface IUserRepository {
  createUser(userData: any): Promise<any>;
  getUserByEmail(email: string): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
}
