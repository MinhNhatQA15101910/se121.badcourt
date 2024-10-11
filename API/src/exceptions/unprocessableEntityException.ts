import { HttpException } from "./httpException";

export class UnprocessableEntityException extends HttpException {
  constructor(message: string, errors: any) {
    super(message, 422, errors);
  }
}
