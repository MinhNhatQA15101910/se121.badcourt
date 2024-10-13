import { IFacilityRepository } from "../interfaces/repositories/IFacilityRepository";
import { PagedList } from "../helper/pagedList";
import { injectable } from "inversify";
import { FacilityParams } from "../schemas/facility/facilityParams";
import { Query } from "mongoose";
import Facility from "../models/facility";

@injectable()
export class FacilityRepository implements IFacilityRepository {
  async getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>> {
    let query: Query<any[], any> = Facility.find();

    if (facilityParams.province) {
      query = query.where("province", facilityParams.province);
    }

    // query = query.sort({
    //   [facilityParams.sortBy]: facilityParams.order === "asc" ? 1 : -1,
    // });

    // console.log("4. ok");

    return await PagedList.create<any>(
      query,
      facilityParams.pageNumber,
      facilityParams.pageSize
    );
  }
}
