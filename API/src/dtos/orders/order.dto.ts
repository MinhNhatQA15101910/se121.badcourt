import { TimePeriodDto } from "../active/timePeriod.dto";
import { FileDto } from "../files/file.dto";

export class OrderDto {
  _id: string = "";
  facilityName: string = "";
  address: string = "";
  price: number = 0;
  image: FileDto;
  timePeriod: TimePeriodDto;
  createdAt: number = 0;

  public static mapFrom(order: any): OrderDto {
    return new OrderDto(order);
  }

  private constructor(order: any) {
    this._id = order === null ? "" : order._id;
    this.facilityName = order === null ? "" : order.facilityName;
    this.address = order === null ? "" : order.address;
    this.price = order === null ? 0 : order.price;
    this.image = FileDto.mapFrom(order === null ? null : order.image);
    this.timePeriod = TimePeriodDto.mapFrom(
      order === null ? null : order.timePeriod
    );
    this.createdAt = order === null ? 0 : order.createdAt;
  }
}
