import { inject, injectable } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { IFacilityRepository } from "../interfaces/repositories/IFacilityRepository";
import { FacilityParamsSchema } from "../schemas/facility/facilityParams";

@injectable()
export class FacilityController {
  private _facilityRepository: IFacilityRepository;

  constructor(
    @inject(INTERFACE_TYPE.FacilityRepository)
    facilityRepository: IFacilityRepository
  ) {
    this._facilityRepository = facilityRepository;
  }

  async getFacilities(req: Request, res: Response) {
    const facilityParams = FacilityParamsSchema.parse(req.query);

    const facilities = await this._facilityRepository.getFacilities(
      facilityParams
    );

    res.send(facilities);
  }
}
