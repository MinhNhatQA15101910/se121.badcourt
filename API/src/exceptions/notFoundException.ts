import { HttpException } from "./httpException";

export class NotFoundException extends HttpException {
  constructor(message: string) {
    super(message, 404, null);
  }
}
