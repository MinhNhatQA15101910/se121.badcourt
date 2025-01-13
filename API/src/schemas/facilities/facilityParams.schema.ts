import { z } from "zod";

export const FacilityParamsSchema = z.object({
  userId: z.string().optional(),
  lat: z
    .preprocess(
      (l) => parseFloat(z.string().parse(l)),
      z.number().min(-90).max(90)
    )
    .default("0"),
  lon: z
    .preprocess(
      (l) => parseFloat(z.string().parse(l)),
      z.number().min(-180).max(180)
    )
    .default("0"),
  pageNumber: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("1"),
  pageSize: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("10"),
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
