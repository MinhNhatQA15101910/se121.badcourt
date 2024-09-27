export interface IUserRepository {
  createUser(userData: any): Promise<any>;
  getUserByEmailAndRole(email: string, role: string): Promise<any>;
}
