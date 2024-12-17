import { RegisterFacilityDto } from "../../dtos/registerFacility.dto";
import { PagedList } from "../../helper/pagedList";
import { FacilityParams } from "../../params/facility.params";

export interface IFacilityRepository {
  getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>>;
  getFacilityByName(facilityName: string): Promise<any>;
  registerFacility(registerFacilityDto: RegisterFacilityDto): Promise<any>;
}