import { TimePeriodDto } from "../active/timePeriod.dto";

export class NewOrderDto {
  userId?: string;
  courtId: string = "";
  timePeriod?: TimePeriodDto;
  address?: string;
  facilityName?: string;
  price?: number;
  image?: any;
}
