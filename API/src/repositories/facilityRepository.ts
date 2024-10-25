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

    if (facilityParams.sortBy === "location") {
      if (facilityParams.order === "asc") {
        try {
          query = query
            .find({
              location: {
                $near: {
                  $geometry: {
                    type: "Point",
                    coordinates: [facilityParams.lon, facilityParams.lat],
                  },
                },
              },
            });
        } catch (err) {
          console.log(err);
        }
      }
      // } else {
      //   query = query.near({
      //     type: "Point",
      //     coordinates: [facilityParams.lon, facilityParams.lat],
      //   });
      // }
    }

    // console.log("4. ok");

    return await PagedList.create<any>(
      query,
      facilityParams.pageNumber,
      facilityParams.pageSize
    );
  }
}
