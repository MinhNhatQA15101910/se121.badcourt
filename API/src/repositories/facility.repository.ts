import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { PagedList } from "../helper/pagedList";
import { injectable } from "inversify";
import { Aggregate } from "mongoose";
import Facility from "../models/facility";
import { FacilityParams } from "../params/facility.params";
import { RegisterFacilityDto } from "../dtos/facilities/registerFacility.dto";
import Court from "../models/court";

@injectable()
export class FacilityRepository implements IFacilityRepository {
  async getFacilityById(facilityId: string): Promise<any> {
    return await Facility.findById(facilityId);
  }

  async getFacilities(facilityParams: FacilityParams): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = Facility.aggregate([]);

    switch (facilityParams.sortBy) {
      case "location":
        aggregate = aggregate
          .near({
            near: [facilityParams.lon, facilityParams.lat],
            distanceField: "distance",
            spherical: true,
          })
          .sort({ distance: facilityParams.order === "asc" ? 1 : -1 });
        break;
      case "registeredAt":
        aggregate = aggregate.sort({
          registeredAt: facilityParams.order === "asc" ? 1 : -1,
        });
        break;
      case "price":
        aggregate = aggregate
          .addFields({
            avgPrice: { $avg: ["$minPrice", "$maxPrice"] },
          })
          .sort({ avgPrice: facilityParams.order === "asc" ? 1 : -1 });
    }

    if (facilityParams.userId) {
      aggregate = aggregate.match({ userId: facilityParams.userId });
    }

    if (facilityParams.province) {
      aggregate = aggregate.match({ province: facilityParams.province });
    }

    aggregate = aggregate.match({
      minPrice: {
        $gte: facilityParams.minPrice,
      },
      maxPrice: {
        $lte: facilityParams.maxPrice,
      },
    });

    const pipeline = aggregate.pipeline();
    let countAggregate = Facility.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      facilityParams.pageNumber,
      facilityParams.pageSize
    );
  }

  async getFacilityByName(facilityName: string): Promise<any> {
    return await Facility.findOne({ name: facilityName });
  }

  async getFacilityProvinces(): Promise<string[]> {
    return await Facility.distinct("province");
  }

  async getMaxPrice(facilityId: string): Promise<number> {
    const courts = await Court.find({ facilityId });

    let maxPrice = courts[0].pricePerHour;
    for (let i = 1; i < courts.length; i++) {
      maxPrice = Math.max(maxPrice, courts[i].pricePerHour);
    }

    return maxPrice;
  }

  async getMinPrice(facilityId: string): Promise<number> {
    const courts = await Court.find({ facilityId });

    let minPrice = courts[0].pricePerHour;
    for (let i = 1; i < courts.length; i++) {
      minPrice = Math.min(minPrice, courts[i].pricePerHour);
    }

    return minPrice;
  }

  async registerFacility(
    registerFacilityDto: RegisterFacilityDto
  ): Promise<any> {
    let facility = new Facility({
      userId: registerFacilityDto.userId,
      facilityName: registerFacilityDto.facilityName,
      facebookUrl: registerFacilityDto.facebookUrl,
      description: registerFacilityDto.description,
      policy: registerFacilityDto.policy,
      detailAddress: registerFacilityDto.detailAddress,
      province: registerFacilityDto.province,
      location: {
        type: "Point",
        coordinates: [registerFacilityDto.lon, registerFacilityDto.lat],
      },
      facilityImages: registerFacilityDto.facilityImages,
      managerInfo: {
        fullName: registerFacilityDto.fullName,
        email: registerFacilityDto.email,
        phoneNumber: registerFacilityDto.phoneNumber,
        citizenId: registerFacilityDto.citizenId,
        citizenImageFront: registerFacilityDto.citizenImageFront,
        citizenImageBack: registerFacilityDto.citizenImageBack,
        bankCardFront: registerFacilityDto.bankCardFront,
        bankCardBack: registerFacilityDto.bankCardBack,
        businessLicenseImages: registerFacilityDto.businessLicenseImages,
      },
    });
    facility = await facility.save();
    return facility;
  }
}
