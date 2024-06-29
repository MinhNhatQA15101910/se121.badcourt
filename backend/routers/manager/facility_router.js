// Packages
import express from "express";

// Models
import Facility from "../../models/facility.js";
import User from "../../models/user.js";

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

// Params middleware
import facilityIdValidator from "../../middleware/params/facility_id_validator.js";

const facilityRouter = express.Router();

// Register facility route
facilityRouter.post(
  "/manager/register-facility",
  managerValidator,
  facilityNameValidator,
  latitudeValidator,
  longitudeValidator,
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

      // Save manager info
      let user = await User.findById(req.user);
      user.manager_info = {
        full_name,
        email,
        citizen_id,
        citizen_image_url_front,
        citizen_image_url_back,
        bank_card_url_front,
        bank_card_url_back,
        business_license_image_urls,
      };
      user = await user.save();

      // Create new facility
      let facility = new Facility({
        user_id: req.user,
        name: facility_name,
        facebook_url,
        phone_number,
        detail_address,
        province,
        latitude: lat,
        longitude: lon,
        registered_at: new Date(),
        image_urls: facility_image_urls,
      });
      facility = await facility.save();

      res.json(facility);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get all facilities route
facilityRouter.get(
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
facilityRouter.get(
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

export default facilityRouter;
