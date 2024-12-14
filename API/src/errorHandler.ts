import { Request, Response, NextFunction } from "express";
import { HttpException } from "./exceptions/http.exception";
import { ZodError } from "zod";
import { UnprocessableEntityException } from "./exceptions/unprocessableEntity.exception";
import { InternalServerException } from "./exceptions/internalServer.exception";

export const errorHandler = (method: Function) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      await method(req, res, next);
    } catch (error) {
      let exception: HttpException;

      if (error instanceof HttpException) {
        exception = error;
      } else {
        if (error instanceof ZodError) {
          exception = new UnprocessableEntityException(
            "Unprocessable entity",
            error
          );
        } else {
          exception = new InternalServerException(
            "Something went wrong!",
            error
          );
        }
      }

      next(exception);
    }
  };
};
