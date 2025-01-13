import { injectable } from "inversify";
import { NewCourtDto } from "../dtos/courts/newCourt.dto";
import { ICourtRepository } from "../interfaces/repositories/ICourt.repository";
import Court from "../models/court";

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
}
