// Packages
import express from "express";

// Header middleware
import managerValidator from "../../middleware/header/manager_validator.js";

// Body middleware
import facilityIdFromBodyValidator from "../../middleware/body/facility_id_validator.js";
import nameValidator from "../../middleware/body/name_validator.js";
import descriptionValidator from "../../middleware/body/description_validator.js";
import pricePerHourValidator from "../../middleware/body/price_per_hour_validator.js";
import Facility from "../../models/facility.js";

// Models
import Court from "../../models/court.js";

const managerCourtRouter = express.Router();

// Add court route
managerCourtRouter.post(
  "/manager/add-court",
  managerValidator,
  facilityIdFromBodyValidator,
  nameValidator,
  descriptionValidator,
  pricePerHourValidator,
  async (req, res) => {
    try {
      const { facility_id, name, description, price_per_hour } = req.body;

      let existingFacility = await Facility.findOne({
        _id: facility_id,
        user_id: req.user,
      });
      if (!existingFacility) {
        return res
          .status(400)
          .json({ msg: "You are not the owner of this facility." });
      }
      existingFacility.courts_amount = existingFacility.courts_amount++;
      await existingFacility.save();

      let court = new Court({
        facility_id,
        name,
        description,
        price_per_hour,
      });
      court = await court.save();
      res.json(court);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default managerCourtRouter;
