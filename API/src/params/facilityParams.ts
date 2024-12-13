import { PaginationParams } from "./paginationParams";

export interface FacilityParams extends PaginationParams {
  minPrice: number;
  maxPrice: number;
  lat: number;
  lon: number;
  sortBy: string;
  order: string;
  province?: string | undefined;
}
