import { injectable } from "inversify";
import { Request, Response } from "express";
import { UserDto } from "../dtos/userDto";
import _ from "lodash";

@injectable()
export class UserController {
  getCurrentUser(req: Request, res: Response) {
    const user = (req as any).user;
    const userDto = new UserDto();
    _.assign(userDto, _.pick(user, _.keys(userDto)));

    res.json(userDto);
  }
}
