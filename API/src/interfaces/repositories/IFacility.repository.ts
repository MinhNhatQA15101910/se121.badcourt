import { RegisterFacilityDto } from "../../dtos/facilities/registerFacility.dto";
import { PagedList } from "../../helper/pagedList";
import { FacilityParams } from "../../params/facility.params";

export interface IFacilityRepository {
  getFacilityById(facilityId: string): Promise<any>;
  getFacilityByName(facilityName: string): Promise<any>;
  getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>>;
  getFacilityProvinces(): Promise<string[]>;
  getMaxPrice(facilityId: string): Promise<number>;
  getMinPrice(facilityId: string): Promise<number>;
  registerFacility(registerFacilityDto: RegisterFacilityDto): Promise<any>;
}
