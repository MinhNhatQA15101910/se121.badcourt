import { PaginationParams } from "./pagination.params";

export class UserParams extends PaginationParams {
  currentUserId?: string;
  username?: string;
  email?: string;
  role?: string;
  sortBy: string = "username";
  order: string = "asc";
}
