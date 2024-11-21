import { injectable } from "inversify";
import { Request, Response } from "express";

@injectable()
export class UserController {
  getCurrentUser(req: Request, res: Response) {
    res.json((req as any).user);
  }
}
