import { z } from "zod";

export const NewTimePeriodSchema = z.object({
  hourFrom: z.number().int().min(0),
  hourTo: z.number().int(),
});
