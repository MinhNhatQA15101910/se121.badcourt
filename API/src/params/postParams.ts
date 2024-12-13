import { PaginationParams } from "./paginationParams";

export class PostParams extends PaginationParams {
  category?: string;
  sortBy: string = "createdAt";
  order: string = "desc";
}
