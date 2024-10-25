export class HttpException extends Error {
  message: string;
  statusCode: number;
  errors: any;

  constructor(
    message: string,
    statusCode: number,
    errors: any
  ) {
    super(message);
    this.message = message;
    this.statusCode = statusCode;
    this.errors = errors;
  }
}
