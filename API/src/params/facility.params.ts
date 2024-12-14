import { PaginationParams } from "./pagination.params";

export class FacilityParams extends PaginationParams {
  minPrice: number = 0;
  maxPrice: number = 1000000;
  lat: number = 0;
  lon: number = 0;
  sortBy: string = "location";
  order: string = "asc";
  province?: string | undefined;
}
