import { HttpException } from "./httpException";

export class BadRequestException extends HttpException {
  constructor(message: string) {
    super(message, 400, null);
  }
}
