import { HttpException } from "./http.exception";

export class UnauthorizedException extends HttpException {
  constructor(message: string, errors?: any) {
    super(message, 401, errors);
  }
}
