import { Container } from "inversify";
import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { FacilityRepository } from "../repositories/facility.repository";
import { FacilityController } from "../controllers/facility.controller";
import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware";
import { errorHandler } from "../errorHandler";
import { upload } from "../middlewares/multer.middleware";
import { managerMiddleware } from "../middlewares/manager.middleware";
import { IFileService } from "../interfaces/services/IFile.service";
import { FileService } from "../services/file.service";
import { IJwtService } from "../interfaces/services/IJwt.service";
import { JwtService } from "../services/jwt.service";
import { IUserRepository } from "../interfaces/repositories/IUser.repository";
import { UserRepository } from "../repositories/user.repository";
import { IBcryptService } from "../interfaces/services/IBcrypt.service";
import { BcryptService } from "../services/bcrypt.service";

const container = new Container();

container.bind<IBcryptService>(INTERFACE_TYPE.BcryptService).to(BcryptService);
container.bind<IFileService>(INTERFACE_TYPE.FileService).to(FileService);
container.bind<IJwtService>(INTERFACE_TYPE.JwtService).to(JwtService);

container
  .bind<IFacilityRepository>(INTERFACE_TYPE.FacilityRepository)
  .to(FacilityRepository);
container
  .bind<IUserRepository>(INTERFACE_TYPE.UserRepository)
  .to(UserRepository);

container.bind(INTERFACE_TYPE.FacilityController).to(FacilityController);

const facilityRoutes: Router = Router();

const facilityController = container.get<FacilityController>(
  INTERFACE_TYPE.FacilityController
);

facilityRoutes.get(
  "/:id",
  errorHandler(facilityController.getFacility.bind(facilityController))
);

facilityRoutes.get(
  "/",
  [authMiddleware],
  errorHandler(facilityController.getFacilities.bind(facilityController))
);

facilityRoutes.post(
  "/",
  [authMiddleware],
  [managerMiddleware],
  upload.fields([
    { name: "facilityImages", maxCount: 10 },
    { name: "citizenImageFront", maxCount: 1 },
    { name: "citizenImageBack", maxCount: 1 },
    { name: "bankCardFront", maxCount: 1 },
    { name: "bankCardBack", maxCount: 1 },
    { name: "businessLicenseImages", maxCount: 10 },
  ]),
  errorHandler(facilityController.registerFacility.bind(facilityController))
);

facilityRoutes.patch(
  "/update-active/:id",
  [authMiddleware],
  errorHandler(facilityController.updateActive.bind(facilityController))
);

export default facilityRoutes;
