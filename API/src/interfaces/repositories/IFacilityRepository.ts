import { RegisterFacilityDto } from "../../dtos/registerFacilityDto";
import { PagedList } from "../../helper/pagedList";
import { FacilityParams } from "../../params/facilityParams";

export interface IFacilityRepository {
  getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>>;
  getFacilityByName(facilityName: string): Promise<any>;
  registerFacility(registerFacilityDto: RegisterFacilityDto): Promise<any>;
}
