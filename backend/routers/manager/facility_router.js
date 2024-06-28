import express from "express";

import managerValidator from "../../middleware/header/manager_validator.js";

const facilityRouter = express.Router();

// Register facility route
facilityRouter.post(
  "/manager/register-facility",
  managerValidator,
  async (req, res) => {
    try {
      const {
        facility_name,
        lat,
        lon,
        detail_address,
        facebook_url,
        image_urls,
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
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default facilityRouter;
