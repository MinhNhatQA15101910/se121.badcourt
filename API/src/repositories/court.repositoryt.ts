import { injectable } from "inversify";
import { NewCourtDto } from "../dtos/courts/newCourt.dto";
import { ICourtRepository } from "../interfaces/repositories/ICourt.repository";
import Court from "../models/court";
import { PagedList } from "../helper/pagedList";
import { CourtParams } from "../params/court.params";
import { Aggregate } from "mongoose";

@injectable()
export class CourtRepository implements ICourtRepository {
  async addCourt(newCourtDto: NewCourtDto): Promise<any> {
    let court = new Court(newCourtDto);
    court = await court.save();
    return court;
  }

  async getCourtById(courtId: string): Promise<any> {
    return await Court.findById(courtId);
  }

  async getCourtByName(courtName: string): Promise<any> {
    return await Court.findOne({ courtName });
  }

  async getCourts(courtParams: CourtParams): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = Court.aggregate([]);

    if (courtParams.facilityId) {
      aggregate = aggregate.match({ facilityId: courtParams.facilityId });
    }

    switch (courtParams.sortBy) {
      case "courtName":
        aggregate = aggregate.sort({
          courtName: courtParams.order === "asc" ? 1 : -1,
        });
        break;
      case "createdAt":
      default:
        aggregate = aggregate.sort({
          createdAt: courtParams.order === "asc" ? 1 : -1,
        });
    }

    const pipeline = aggregate.pipeline();
    let countAggregate = Court.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      courtParams.pageNumber,
      courtParams.pageSize
    );
  }
}
