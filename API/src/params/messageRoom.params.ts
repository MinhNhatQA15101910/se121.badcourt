import { PaginationParams } from "./pagination.params";

export class MessageRoomParams extends PaginationParams {
  userId?: string;
  sortBy?: string = "createdAt";
  order?: string = "desc";
}
