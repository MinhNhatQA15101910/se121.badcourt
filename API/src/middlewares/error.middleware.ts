import { NextFunction, Request, Response } from "express";
import { HttpException } from "../exceptions/http.exception";

export const errorMiddleware = (
  err: HttpException,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  res.status(err.statusCode).json({
    message: err.message,
    errors: err.errors,
  });
};
