import { inject, injectable } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { RegisterFacilitySchema } from "../schemas/facilities/registerFacility.schema";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { IFileService } from "../interfaces/services/IFile.service";
import { FacilityParamsSchema } from "../schemas/facilities/facilityParams.schema";
import { RegisterFacilityDto } from "../dtos/registerFacility.dto";
import { uploadImages } from "../helper/helpers";
import { IJwtService } from "../interfaces/services/IJwt.service";
import { FacilityDto } from "../dtos/facility.dto";

@injectable()
export class FacilityController {
  private _fileService: IFileService;
  private _jwtService: IJwtService;
  private _facilityRepository: IFacilityRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.JwtService) jwtService: IJwtService,
    @inject(INTERFACE_TYPE.FacilityRepository)
    facilityRepository: IFacilityRepository
  ) {
    this._fileService = fileService;
    this._jwtService = jwtService;
    this._facilityRepository = facilityRepository;
  }

  async getFacilities(req: Request, res: Response) {
    const facilityParams = FacilityParamsSchema.parse(req.query);

    const facilities = await this._facilityRepository.getFacilities(
      facilityParams
    );

    var facilityDtos: FacilityDto[] = [];
    for (let facility of facilities) {
      facilityDtos.push(FacilityDto.mapFrom(facility));
    }

    res.json(facilityDtos);
  }

  async registerFacility(req: Request, res: Response) {
    const registerFacilityDto: RegisterFacilityDto =
      RegisterFacilitySchema.parse(req.body);

    // Check duplicate facility name
    const existingFacility = await this._facilityRepository.getFacilityByName(
      registerFacilityDto.facilityName
    );
    if (existingFacility) {
      throw new BadRequestException("Facility name already exists!");
    }

    // Set current user id
    const user = req.user;
    registerFacilityDto.userId = user._id;

    let facility = await this._facilityRepository.registerFacility(
      registerFacilityDto
    );

    let managerInfo = facility.managerInfo;

    // Upload facility images
    const facilityImages = await uploadImages(
      this._fileService,
      (req.files as any).facilityImages,
      `facilities/${facility._id}/facility_images`
    );
    facility.facilityImages = facilityImages;

    // Upload citizen image front
    if ((req.files as any).citizenImageFront) {
      const citizenImageFront = (
        await uploadImages(
          this._fileService,
          (req.files as any).citizenImageFront,
          `facilities/${facility._id}/citizen_images`
        )
      )[0];
      managerInfo.citizenImageFront = citizenImageFront;
    }

    // Upload citizen image front
    if ((req.files as any).citizenImageBack) {
      const citizenImageBack = (
        await uploadImages(
          this._fileService,
          (req.files as any).citizenImageBack,
          `facilities/${facility._id}/citizen_images`
        )
      )[0];
      managerInfo.citizenImageBack = citizenImageBack;
    }

    // Upload bank card image front
    if ((req.files as any).bankCardFront) {
      const bankCardFront = (
        await uploadImages(
          this._fileService,
          (req.files as any).bankCardFront,
          `facilities/${facility._id}/bank_card_images`
        )
      )[0];
      managerInfo.bankCardFront = bankCardFront;
    }

    // Upload bank card image back
    if ((req.files as any).bankCardBack) {
      const bankCardBack = (
        await uploadImages(
          this._fileService,
          (req.files as any).bankCardBack,
          `facilities/${facility._id}/bank_card_images`
        )
      )[0];
      managerInfo.bankCardBack = bankCardBack;
    }

    // Upload business licenses
    if ((req.files as any).businessLicenseImages) {
      const businessLicenseImages = await uploadImages(
        this._fileService,
        (req.files as any).businessLicenseImages,
        `facilities/${facility._id}/business_license_images`
      );
      managerInfo.businessLicenseImages = businessLicenseImages;
    }

    facility.managerInfo = managerInfo;
    facility = await facility.save();

    res.json(facility);
  }
}
