import { inject, injectable } from "inversify";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { Request, Response } from "express";
import { IFacilityRepository } from "../interfaces/repositories/IFacilityRepository";
import { RegisterFacilitySchema } from "../schemas/facility/registerFacility";
import { BadRequestException } from "../exceptions/badRequestException";
import { IFileService } from "../interfaces/services/IFileService";
import { FacilityParamsSchema } from "../schemas/facility/facilityParams";
import { RegisterFacilityDto } from "../dtos/registerFacilityDto";
import { FileDto } from "../dtos/fileDto";
import { uploadImages } from "../helper/helpers";

@injectable()
export class FacilityController {
  private _fileService: IFileService;
  private _facilityRepository: IFacilityRepository;

  constructor(
    @inject(INTERFACE_TYPE.FileService) fileService: IFileService,
    @inject(INTERFACE_TYPE.FacilityRepository)
    facilityRepository: IFacilityRepository
  ) {
    this._fileService = fileService;
    this._facilityRepository = facilityRepository;
  }

  async getFacilities(req: Request, res: Response) {
    const facilityParams = FacilityParamsSchema.parse(req.query);

    const facilities = await this._facilityRepository.getFacilities(
      facilityParams
    );

    res.json(facilities);
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

    const user = (req as any).user;
    registerFacilityDto.userId = user._id;

    // Upload facility images
    const facilityImages = await uploadImages(
      this._fileService,
      (req.files as any).facilityImages,
      `${user.username}/${registerFacilityDto.facilityName}/facility_images`
    );
    registerFacilityDto.facilityImages = facilityImages;

    // Upload citizen image front
    const citizenImageFront = (
      await uploadImages(
        this._fileService,
        (req.files as any).citizenImageFront,
        `${user.username}/${registerFacilityDto.facilityName}/citizen_images`
      )
    )[0];
    registerFacilityDto.citizenImageFront = citizenImageFront;

    // Upload citizen image front
    const citizenImageBack = (
      await uploadImages(
        this._fileService,
        (req.files as any).citizenImageBack,
        `${user.username}/${registerFacilityDto.facilityName}/citizen_images`
      )
    )[0];
    registerFacilityDto.citizenImageBack = citizenImageBack;

    // Upload bank card image front
    const bankCardFront = (
      await uploadImages(
        this._fileService,
        (req.files as any).bankCardFront,
        `${user.username}/${registerFacilityDto.facilityName}/bank_card_images`
      )
    )[0];
    registerFacilityDto.bankCardFront = bankCardFront;

    // Upload bank card image back
    const bankCardBack = (
      await uploadImages(
        this._fileService,
        (req.files as any).bankCardBack,
        `${user.username}/${registerFacilityDto.facilityName}/bank_card_images`
      )
    )[0];
    registerFacilityDto.bankCardBack = bankCardBack;

    // Upload business licenses
    const businessLicenseImages = await uploadImages(
      this._fileService,
      (req.files as any).businessLicenseImages,
      `${user.username}/${registerFacilityDto.facilityName}/business_license_images`
    );
    registerFacilityDto.businessLicenseImages = businessLicenseImages;

    const facility = await this._facilityRepository.registerFacility(
      registerFacilityDto
    );

    res.json(facility);
  }
}
