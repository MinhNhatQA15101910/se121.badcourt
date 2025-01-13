import { inject, injectable } from "inversify";
import { Request, Response } from "express";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { NotFoundException } from "../exceptions/notFound.exception";
import { ICourtRepository } from "../interfaces/repositories/ICourt.repository";
import { NewCourtDto } from "../dtos/courts/newCourt.dto";
import { AddCourtSchema } from "../schemas/courts/addCourt.schema";
import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { CourtDto } from "../dtos/courts/court.dto";
import { PORT } from "../secrets";
import { addPaginationHeader } from "../helper/helpers";
import { CourtParams } from "../params/court.params";
import { CourtParamsSchema } from "../schemas/courts/courtParams.schema";

@injectable()
export class CourtController {
  private _courtRepository: ICourtRepository;
  private _facilityRepository: IFacilityRepository;

  constructor(
    @inject(INTERFACE_TYPE.CourtRepository) courtRepository: ICourtRepository,
    @inject(INTERFACE_TYPE.FacilityRepository)
    facilityRepository: IFacilityRepository
  ) {
    this._courtRepository = courtRepository;
    this._facilityRepository = facilityRepository;
  }

  async getCourt(req: Request, res: Response) {
    const courtId = req.params.id;

    const court = await this._courtRepository.getCourtById(courtId);
    if (!court) {
      throw new NotFoundException("Court not found!");
    }

    const courtDto = CourtDto.mapFrom(court);

    // Check user role
    res.json(CourtDto.mapFrom(court));
  }

  async getCourts(req: Request, res: Response) {
    const courtParams: CourtParams = CourtParamsSchema.parse(req.query);

    const courts = await this._courtRepository.getCourts(courtParams);

    addPaginationHeader(res, courts);

    const courtDtos: CourtDto[] = [];
    for (let court of courts) {
      const courtDto = CourtDto.mapFrom(court);
      courtDtos.push(courtDto);
    }

    res.json(courtDtos);
  }

  async addCourt(req: Request, res: Response) {
    const user = req.user;

    const newCourtDto: NewCourtDto = AddCourtSchema.parse(req.body);

    // Check if user is authorized to update facility
    const facility = await this._facilityRepository.getFacilityById(
      newCourtDto.facilityId
    );
    if (!facility) {
      throw new NotFoundException("Facility not found!");
    }
    if (
      user.role !== "admin" &&
      facility.userId.toString() !== user._id.toString()
    ) {
      throw new NotFoundException("You are not authorized to add court!");
    }

    // Check if the court name exists
    const existingCourt = await this._courtRepository.getCourtByName(
      newCourtDto.courtName
    );
    if (existingCourt) {
      throw new NotFoundException("Court name already exists!");
    }

    // Add court to database
    const court = await this._courtRepository.addCourt(newCourtDto);

    // Update facility price
    if (facility.courtsAmount === 0) {
      facility.minPrice = newCourtDto.pricePerHour;
      facility.maxPrice = newCourtDto.pricePerHour;
    } else {
      facility.minPrice = Math.min(facility.minPrice, newCourtDto.pricePerHour);
      facility.maxPrice = Math.max(facility.maxPrice, newCourtDto.pricePerHour);
    }

    // Update facility courts
    facility.courtsAmount++;

    facility.updatedAt = new Date();
    await facility.save();

    res
      .status(201)
      .location(`https://localhost:${PORT}/api/courts/${court._id}`)
      .json(CourtDto.mapFrom(court));
  }
}
