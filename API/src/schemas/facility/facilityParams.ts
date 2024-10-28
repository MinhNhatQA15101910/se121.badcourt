import { z } from "zod";
import { PaginationParams } from "../paginationParams";

export interface FacilityParams extends PaginationParams {
  minPrice: number;
  maxPrice: number;
  lat: number;
  lon: number;
  sortBy: string;
  order: string;
  province?: string | undefined;
}

export const FacilityParamsSchema = z.object({
  lat: z.preprocess(
    (l) => parseFloat(z.string().parse(l)),
    z.number().min(-90).max(90)
  ),
  lon: z.preprocess(
    (l) => parseFloat(z.string().parse(l)),
    z.number().min(-180).max(180)
  ),
  pageNumber: z.number().int().min(1).default(1),
  pageSize: z.number().int().min(1).default(10),
  province: z.string().optional(),
  minPrice: z
    .preprocess(
      (p) => parseFloat(z.string().parse(p)),
      z.number().min(0).default(0)
    )
    .default("0"),
  maxPrice: z
    .preprocess(
      (p) => parseFloat(z.string().parse(p)),
      z.number().int().positive().default(10000000)
    )
    .default("10000000"),
  sortBy: z.string().optional().default("location"),
  order: z.string().optional().default("asc"),
});
