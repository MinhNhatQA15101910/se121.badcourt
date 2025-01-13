import { z } from "zod";

export const CreateOrderSchema = z.object({
  courtId: z.string(),
  timePeriod: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
});
