import { PagedList } from "../../helper/pagedList";
import { FacilityParams } from "../../schemas/facility/facilityParams";

export interface IFacilityRepository {
  getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>>;
}
