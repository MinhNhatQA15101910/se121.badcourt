import { TimePeriodDto } from "./timePeriod.dto";

export class ActiveDto {
  monday?: TimePeriodDto;
  tuesday?: TimePeriodDto;
  wednesday?: TimePeriodDto;
  thursday?: TimePeriodDto;
  friday?: TimePeriodDto;
  saturday?: TimePeriodDto;
  sunday?: TimePeriodDto;

  public static mapFrom(active: any): ActiveDto {
    return new ActiveDto(active);
  }

  private constructor(active: any) {
    if (active.monday) {
      this.monday = TimePeriodDto.mapFrom(active.monday);
    }

    if (active.tuesday) {
      this.tuesday = TimePeriodDto.mapFrom(active.tuesday);
    }

    if (active.wednesday) {
      this.wednesday = TimePeriodDto.mapFrom(active.wednesday);
    }

    if (active.thursday) {
      this.thursday = TimePeriodDto.mapFrom(active.thursday);
    }

    if (active.friday) {
      this.friday = TimePeriodDto.mapFrom(active.friday);
    }

    if (active.saturday) {
      this.saturday = TimePeriodDto.mapFrom(active.saturday);
    }

    if (active.sunday) {
      this.sunday = TimePeriodDto.mapFrom(active.sunday);
    }
  }
}
