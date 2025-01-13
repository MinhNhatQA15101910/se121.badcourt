export class TimePeriodDto {
  hourFrom: number = 0;
  hourTo: number = 0;

  public static mapFrom(timePeriod: any): TimePeriodDto {
    return new TimePeriodDto(timePeriod);
  }

  private constructor(timePeriod: any) {
    this.hourFrom = timePeriod === null ? 0 : timePeriod.hourFrom;
    this.hourTo = timePeriod === null ? 0 : timePeriod.hourTo;
  }
}
