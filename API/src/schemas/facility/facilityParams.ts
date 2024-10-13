import { z } from "zod";
import { PaginationParams } from "../paginationParams";

export interface FacilityParams extends PaginationParams {
  minPrice: number;
  maxPrice: number;
  sortBy: string;
  order: string;
  province?: string | undefined;
}

export const FacilityParamsSchema = z.object({
  pageNumber: z.number().int().min(1).default(1),
  pageSize: z.number().int().min(1).default(10),
  province: z.string().optional(),
  minPrice: z.number().int().min(0).default(0),
  maxPrice: z.number().int().positive().default(10000000),
  sortBy: z.string().optional().default("location"),
  order: z.string().optional().default("asc"),
});
