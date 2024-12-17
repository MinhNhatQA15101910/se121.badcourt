import { PaginationParams } from "./pagination.params";

export class CommentParams extends PaginationParams {
  postId?: string;
  sortBy: string = "createdAt";
  order: string = "desc";
}
