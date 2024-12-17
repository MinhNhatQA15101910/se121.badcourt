import { HttpException } from "./http.exception";

export class InternalServerException extends HttpException {
  constructor(message: string, errors: any) {
    super(message, 500, errors);
  }
}
