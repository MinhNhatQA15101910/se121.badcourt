import { PaginationParams } from "./pagination.params";

export class OrderParams extends PaginationParams {
  userId?: string;
  courtId?: string;
  state?: string;
  sortBy?: string = "createdAt";
  order?: string = "desc";
}
