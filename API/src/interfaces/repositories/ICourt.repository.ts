import { NewCourtDto } from "../../dtos/courts/newCourt.dto";

export interface ICourtRepository {
  addCourt(newCourtDto: NewCourtDto): Promise<any>;
}
