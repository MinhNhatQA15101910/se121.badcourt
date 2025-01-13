import { z } from "zod";

export const UpdateCourtSchema = z.object({
  courtName: z.string().optional(),
  description: z.string().optional(),
  pricePerHour: z.number().optional(),
});
