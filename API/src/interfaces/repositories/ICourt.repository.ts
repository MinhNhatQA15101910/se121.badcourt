import { NewCourtDto } from "../../dtos/courts/newCourt.dto";
import { PagedList } from "../../helper/pagedList";
import { CourtParams } from "../../params/court.params";

export interface ICourtRepository {
  addCourt(newCourtDto: NewCourtDto): Promise<any>;
  getCourtById(courtId: string): Promise<any>;
  getCourtByName(courtName: string): Promise<any>;
  getCourts(courtParams: CourtParams): Promise<PagedList<any>>;
}
