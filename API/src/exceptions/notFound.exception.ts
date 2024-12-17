import { HttpException } from "./http.exception";

export class NotFoundException extends HttpException {
  constructor(message: string) {
    super(message, 404, null);
  }
}
