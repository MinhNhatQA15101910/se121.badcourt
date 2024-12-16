import { PaginationParams } from "./pagination.params";

export class PostParams extends PaginationParams {
  userId?: string;
  category?: string;
  sortBy: string = "createdAt";
  order: string = "desc";
}
