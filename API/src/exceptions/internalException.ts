import { HttpException } from "./httpException";

export class InternalException extends HttpException {
  constructor(message: string, errors: any) {
    super(message, 500, errors);
  }
}
