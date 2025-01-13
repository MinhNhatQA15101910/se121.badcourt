import { TimePeriodDto } from "./timePeriod.dto";

export class ActiveDto {
  monday?: TimePeriodDto;
  tuesday: TimePeriodDto;
  wednesday: TimePeriodDto;
  thursday: TimePeriodDto;
  friday: TimePeriodDto;
  saturday: TimePeriodDto;
  sunday: TimePeriodDto;

  public static mapFrom(active: any): ActiveDto {
    return new ActiveDto(active);
  }

  private constructor(active: any) {
    this.monday = TimePeriodDto.mapFrom(active === null ? null : active.monday);
    this.tuesday = TimePeriodDto.mapFrom(
      active === null ? null : active.tuesday
    );
    this.wednesday = TimePeriodDto.mapFrom(
      active === null ? null : active.wednesday
    );
    this.thursday = TimePeriodDto.mapFrom(
      active === null ? null : active.thursday
    );
    this.friday = TimePeriodDto.mapFrom(active === null ? null : active.friday);
    this.saturday = TimePeriodDto.mapFrom(
      active === null ? null : active.saturday
    );
    this.sunday = TimePeriodDto.mapFrom(active === null ? null : active.sunday);
  }
}
