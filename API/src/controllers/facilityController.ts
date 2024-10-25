import { inject, injectable } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { IFacilityRepository } from "../interfaces/repositories/IFacilityRepository";

// Testing
import { v2 as cloudinary } from "cloudinary";
import {
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_CLOUD_NAME,
} from "../secrets";

cloudinary.config({
  cloud_name: CLOUDINARY_CLOUD_NAME,
  api_key: CLOUDINARY_API_KEY,
  api_secret: CLOUDINARY_API_SECRET,
});

@injectable()
export class FacilityController {
  private _facilityRepository: IFacilityRepository;

  constructor(
    @inject(INTERFACE_TYPE.FacilityRepository)
    facilityRepository: IFacilityRepository
  ) {
    this._facilityRepository = facilityRepository;
  }

  // async getFacilities(req: Request, res: Response) {
  //   const facilityParams = FacilityParamsSchema.parse(req.query);

  //   const facilities = await this._facilityRepository.getFacilities(
  //     facilityParams
  //   );

  //   res.send(facilities);
  // }

  async registerFacility(req: Request, res: Response) {
    res.status(200).json(req.file);
  }

  async uploadFile(req: Request, res: Response) {
    const result = await cloudinary.uploader.upload(req.file?.path!, {
      folder: "BadCourt/me",
    });

    res.status(200).json(result);
  }

  async deleteFile(req: Request, res: Response) {
    cloudinary.uploader.destroy(
      req.body.public_id as string,
      (error, result) => {
        if (error) {
          console.log(error);
          return res.status(500).send();
        }

        res.status(200).json(result);
      }
    );
  }
}
