import { PaginationParams } from "./pagination.params";

export class PostParams extends PaginationParams {
  category?: string;
  sortBy: string = "createdAt";
  order: string = "desc";
}
