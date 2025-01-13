import { PaginationParams } from "./pagination.params";

export class CourtParams extends PaginationParams {
  facilityId?: string;
  sortBy: string = "createdAt";
  order: string = "desc";
}
