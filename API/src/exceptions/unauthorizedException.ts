import { HttpException } from "./httpException";

export class UnauthorizedException extends HttpException {
  constructor(message: string, errors?: any) {
    super(message, 401, errors);
  }
}
