export interface IBcryptService {
  comparePassword(password: string, hash: string): boolean;
}
