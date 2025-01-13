import { z } from "zod";

export const AddCourtSchema = z.object({
  facilityId: z.string(),
  courtName: z.string(),
  description: z.string(),
  pricePerHour: z.number(),
});
