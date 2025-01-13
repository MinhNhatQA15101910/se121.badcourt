import { Container } from "inversify";
import { ICourtRepository } from "../interfaces/repositories/ICourt.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { CourtRepository } from "../repositories/court.repositoryt";
import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { FacilityRepository } from "../repositories/facility.repository";
import { CourtController } from "../controllers/court.controller";
import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware";
import { errorHandler } from "../errorHandler";

const container = new Container();

container
  .bind<ICourtRepository>(INTERFACE_TYPE.CourtRepository)
  .to(CourtRepository);
container
  .bind<IFacilityRepository>(INTERFACE_TYPE.FacilityRepository)
  .to(FacilityRepository);

container.bind(INTERFACE_TYPE.CourtController).to(CourtController);

const courtRoutes: Router = Router();

const courtController = container.get<CourtController>(
  INTERFACE_TYPE.CourtController
);

courtRoutes.post(
  "/",
  [authMiddleware],
  errorHandler(courtController.addCourt.bind(courtController))
);

courtRoutes.get(
  "/:id",
  errorHandler(courtController.getCourt.bind(courtController))
);

export default courtRoutes;
