import { ActiveDto } from "../active/active.dto";
import { FileDto } from "../files/file.dto";
import { ManagerInfoDto } from "./managerInfo.dto";

export class FacilityDto {
  _id: string = "";
  facilityName: string = "";
  facebookUrl?: string = "";
  description: string = "";
  policy: string = "";
  userId: string = "";
  userImageUrl: string = "";
  facilityImageUrl: string = "";
  facilityImages: FileDto[] = [];
  activeAt: any;
  courtsAmount: number = 0;
  minPrice: number = 0;
  maxPrice: number = 0;
  detailAddress: string = "";
  province: string = "";
  lat: number = 0;
  lon: number = 0;
  ratingAvg: number = 0;
  totalRating: number = 0;
  managerInfo?: ManagerInfoDto;
  state: string = "";
  createdAt: number = 0;

  public static mapFrom(facility: any): FacilityDto {
    return new FacilityDto(facility);
  }

  private constructor(facility: any) {
    this._id = facility === null ? "" : facility._id;
    this.userId = facility === null ? "" : facility.userId.toString();
    this.facilityName = facility === null ? "" : facility.facilityName;
    this.facebookUrl = facility === null ? "" : facility.facebookUrl;
    this.description = facility === null ? "" : facility.description;
    this.policy = facility === null ? "" : facility.policy;
    this.facilityImageUrl =
      facility === null
        ? ""
        : facility.facilityImages.find((image: any) => image.isMain).url;
    this.facilityImages =
      facility === null
        ? []
        : facility.facilityImages.map((file: any) => FileDto.mapFrom(file));
    this.activeAt = facility.activeAt
      ? ActiveDto.mapFrom(facility.activeAt)
      : null;
    this.courtsAmount = facility === null ? 0 : facility.courtsAmount;
    this.minPrice = facility === null ? 0 : facility.minPrice;
    this.maxPrice = facility === null ? 0 : facility.maxPrice;
    this.detailAddress = facility === null ? "" : facility.detailAddress;
    this.province = facility === null ? "" : facility.province;
    this.lat = facility === null ? 0 : facility.location.coordinates[1];
    this.lon = facility === null ? 0 : facility.location.coordinates[0];
    this.ratingAvg = facility === null ? 0 : facility.ratingAvg;
    this.totalRating = facility === null ? 0 : facility.totalRating;
    this.managerInfo =
      facility === null
        ? undefined
        : ManagerInfoDto.mapFrom(facility.managerInfo);
    this.state = facility === null ? "" : facility.state;
    this.createdAt = facility === null ? 0 : facility.createdAt;
  }
}
