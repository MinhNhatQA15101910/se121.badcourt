import { PaginationHeader } from "../../helper/paginationHeader";

export {};

declare global {
  namespace Express {
    export interface Request {
      user?: User;
    }
  }
}
