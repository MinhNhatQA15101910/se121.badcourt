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
import { NotFoundException } from "../exceptions/notFound.exception";
import { IJwtService } from "../interfaces/services/IJwt.service";

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

    const user = req.user;
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

  async requestFacilityToken(req: Request, res: Response) {
    const user = req.user;
    const facilityId = req.params.facilityId;

    const facility = await this._facilityRepository.getFacilityById(facilityId);
    if (!facility) {
      throw new NotFoundException("Facility not found!");
    }

    if (facility.userId.toString() !== user._id.toString()) {
      throw new BadRequestException("You are not the owner of this facility!");
    }

    const token = this._jwtService.generateToken({
      userId: user._id,
      facilityId: facilityId,
    });

    res.json({ token });
  }
}
