// Packages
import express from "express";

// Header middleware
import managerValidator from "../../middleware/header/manager_validator.js";

// Body middleware
import facilityIdFromBodyValidator from "../../middleware/body/facility_id_validator.js";
import nameValidator from "../../middleware/body/name_validator.js";
import descriptionValidator from "../../middleware/body/description_validator.js";
import pricePerHourValidator from "../../middleware/body/price_per_hour_validator.js";

// Param middleware
import courtIdValidator from "../../middleware/params/court_id_validator.js";

// Models
import Court from "../../models/court.js";
import Facility from "../../models/facility.js";

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
          .status(403)
          .json({ msg: "You are not the facility's owner." });
      }

      const existingCourt = await Court.findOne({ name, facility_id });
      if (existingCourt) {
        return res
          .status(400)
          .json({ msg: "Court with the same name already exists." });
      }

      existingFacility.courts_amount++;
      if (existingFacility.courts_amount === 1) {
        existingFacility.min_price = price_per_hour;
        existingFacility.max_price = price_per_hour;
      } else {
        if (existingFacility.min_price > price_per_hour) {
          existingFacility.min_price = price_per_hour;
        }
        if (existingFacility.max_price < price_per_hour) {
          existingFacility.max_price = price_per_hour;
        }
      }
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

// Update court route
managerCourtRouter.patch(
  "/manager/update-court/:court_id",
  managerValidator,
  courtIdValidator,
  nameValidator,
  descriptionValidator,
  pricePerHourValidator,
  async (req, res) => {
    try {
      const { court_id } = req.params;
      const { name, description, price_per_hour } = req.body;

      let court = await Court.findById(court_id);

      // Check if the current user is the facility's owner
      const facility = await Facility.find({
        _id: court.facility_id,
        user_id: req.user,
      });
      if (!facility) {
        return res
          .status(403)
          .json({ msg: "You are not the facility's owner." });
      }

      // Check if court name has already existed
      const existingCourt = await Court.findOne({
        name,
        facility_id: court.facility_id,
      });
      if (
        existingCourt &&
        existingCourt._id.toString() !== court._id.toString()
      ) {
        return res
          .status(400)
          .json({ msg: "Court with the same name already exists." });
      }

      // Update facility's min_price and max_price
      if (facility.min_price > price_per_hour) {
        facility.min_price = price_per_hour;
      }
      if (facility.max_price < price_per_hour) {
        facility.max_price = price_per_hour;
      }
      await facility.save();

      // Update court
      court.name = name;
      court.description = description;
      court.price_per_hour = price_per_hour;
      court = await court.save();

      res.json(court);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Delete court route
managerCourtRouter.delete(
  "/manager/delete-court/:court_id",
  managerValidator,
  courtIdValidator,
  async (req, res) => {
    try {
      const { court_id } = req.params;

      let court = await Court.findById(court_id);

      let facility = await Facility.findOne({
        _id: court.facility_id,
        user_id: req.user,
      });
      if (!facility) {
        return res
          .status(403)
          .json({ msg: "You are not the facility's owner." });
      }

      if (court.order_periods.length !== 0) {
        return res
          .status(400)
          .json(
            "Cannot delete court because there are bookings to this court."
          );
      }

      court = await Court.findByIdAndDelete(court_id);

      facility.courts_amount--;
      await facility.save();

      res.json(court);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get courts route
managerCourtRouter.get(
  "/manager/courts",
  managerValidator,
  async (req, res) => {
    try {
      const { facility_id } = req.query;

      // Validate if current user is the facility's owner
      let existingFacility = await Facility.findOne({
        _id: facility_id,
        user_id: req.user,
      });
      if (!existingFacility) {
        return res
          .status(403)
          .json({ msg: "You are not the facility's owner." });
      }

      const courts = await Court.find({ facility_id });

      res.json(courts);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default managerCourtRouter;
