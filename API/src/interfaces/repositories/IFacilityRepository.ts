import { PagedList } from "../../helper/pagedList";
import { FacilityParams } from "../../schemas/facility/facilityParams";
import { RegisterFacilityDto } from "../../schemas/facility/registerFacility";

export interface IFacilityRepository {
  getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>>;
  getFacilityByName(facilityName: string): Promise<any>;
  registerFacility(registerFacilityDto: RegisterFacilityDto): Promise<any>;
}
