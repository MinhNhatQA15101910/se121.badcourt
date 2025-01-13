export class CourtDto {
  _id: string = "";
  courtName: string = "";
  description: string = "";
  pricePerHour: string = "";
  state: string = "";
  createdAt: number = 0;

  public static mapFrom(court: any): CourtDto {
    return new CourtDto(court);
  }

  private constructor(court?: any) {
    this._id = court === null ? "" : court._id;
    this.courtName = court === null ? "" : court.courtName;
    this.description = court === null ? "" : court.description;
    this.pricePerHour = court === null ? "" : court.pricePerHour;
    this.state = court === null ? "" : court.state;
    this.createdAt = court === null ? 0 : court.createdAt;
  }
}
