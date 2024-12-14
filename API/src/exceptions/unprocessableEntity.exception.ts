import { HttpException } from "./http.exception";

export class UnprocessableEntityException extends HttpException {
  constructor(message: string, errors: any) {
    super(message, 422, errors);
  }
}
