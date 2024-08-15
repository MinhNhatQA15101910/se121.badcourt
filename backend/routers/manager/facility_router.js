// Packages
import express from "express";

// Models
import Facility from "../../models/facility.js";
import Court from "../../models/court.js";

// Header middleware
import managerValidator from "../../middleware/header/manager_validator.js";

// Body middleware
import facilityNameValidator from "../../middleware/body/facility_name_validator.js";
import latitudeValidator from "../../middleware/body/latitude_validator.js";
import longitudeValidator from "../../middleware/body/longitude_validator.js";
import detailAddressValidator from "../../middleware/body/detail_address_validator.js";
import provinceValidator from "../../middleware/body/province_validator.js";
import fullNameValidator from "../../middleware/body/full_name_validator.js";
import emailValidator from "../../middleware/body/email_validator.js";
import phoneNumberValidator from "../../middleware/body/phone_number_validator.js";
import facilityImageUrlsValidator from "../../middleware/body/facility_image_urls_validator.js";
import citizenIdValidator from "../../middleware/body/citizen_id_validator.js";
import citizenImageUrlValidator from "../../middleware/body/citizen_image_url_validator.js";
import bankCardUrlValidator from "../../middleware/body/bank_card_url_validator.js";
import businessLicenseImageUrlsValidator from "../../middleware/body/business_license_image_urls_validator.js";
import descriptionValidator from "../../middleware/body/description_validator.js";
import policyValidator from "../../middleware/body/policy_validator.js";

// Params middleware
import facilityIdValidator from "../../middleware/params/facility_id_validator.js";
import activeValidator from "../../middleware/body/active_validator.js";

const managerFacilityRouter = express.Router();

// Register facility route
managerFacilityRouter.post(
  "/manager/register-facility",
  managerValidator,
  facilityNameValidator,
  latitudeValidator,
  longitudeValidator,
  descriptionValidator,
  policyValidator,
  detailAddressValidator,
  provinceValidator,
  facilityImageUrlsValidator,
  fullNameValidator,
  emailValidator,
  phoneNumberValidator,
  citizenIdValidator,
  citizenImageUrlValidator,
  bankCardUrlValidator,
  businessLicenseImageUrlsValidator,
  async (req, res) => {
    try {
      const {
        facility_name,
        lat,
        lon,
        description,
        policy,
        detail_address,
        province,
        facebook_url,
        facility_image_urls,
        full_name,
        email,
        phone_number,
        citizen_id,
        citizen_image_url_front,
        citizen_image_url_back,
        bank_card_url_front,
        bank_card_url_back,
        business_license_image_urls,
      } = req.body;

      const existingFacility = await Facility.findOne({ name: facility_name });
      if (existingFacility) {
        return res
          .status(400)
          .json({ msg: "Facility with the same name exists." });
      }

      // Create new facility
      let facility = new Facility({
        user_id: req.user,
        name: facility_name,
        facebook_url,
        detail_address,
        description,
        policy,
        province,
        latitude: lat,
        longitude: lon,
        registered_at: new Date(),
        image_urls: facility_image_urls,
        manager_info: {
          full_name,
          email,
          phone_number,
          citizen_id,
          citizen_image_url_front,
          citizen_image_url_back,
          bank_card_url_front,
          bank_card_url_back,
          business_license_image_urls,
        },
      });
      facility = await facility.save();

      res.json(facility);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get all facilities route
managerFacilityRouter.get(
  "/manager/facilities",
  managerValidator,
  async (req, res) => {
    try {
      const facilities = await Facility.find({ user_id: req.user });
      res.json(facilities);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get facility by id route
managerFacilityRouter.get(
  "/manager/facilities/:facility_id",
  managerValidator,
  facilityIdValidator,
  async (req, res) => {
    try {
      const { facility_id } = req.params;

      const facility = await Facility.findById(facility_id);
      res.json(facility);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Update facility active
managerFacilityRouter.patch(
  "/manager/update-active/:facility_id",
  managerValidator,
  facilityIdValidator,
  activeValidator,
  async (req, res) => {
    try {
      const { facility_id } = req.params;
      const { active } = req.body;

      console.log(req.body);

      let facility = await Facility.findById(facility_id);

      // Check if the user is facility's owner
      if (facility.user_id.toString() !== req.user) {
        return res
          .status(403)
          .json({ msg: "You are not the facility's owner" });
      }

      // Update facility active
      facility.active_at = active;
      facility = await facility.save();

      res.json(facility);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get facility price range
managerFacilityRouter.get(
  "/manager/facilities/price-range/:facility_id",
  managerValidator,
  facilityIdValidator,
  async (req, res) => {
    try {
      const { facility_id } = req.params;

      const courts = await Court.find({ facility_id });

      let minPrice = courts[0].price_per_hour;
      let maxPrice = courts[0].price_per_hour;

      for (let i = 1; i < courts.length; i++) {
        if (courts[i].price_per_hour < minPrice) {
          minPrice = courts[i].price_per_hour;
        }

        if (courts[i].price_per_hour > maxPrice) {
          maxPrice = courts[i].price_per_hour;
        }
      }

      res.json({ minPrice, maxPrice });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default managerFacilityRouter;
