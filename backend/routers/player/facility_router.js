// Packages
import express from "express";

// Models
import Facility from "../../models/facility.js";

// Header middleware
import playerValidator from "../../middleware/header/player_validator.js";
import sortValidator from "../../middleware/query/sort_validator.js";
import facilityIdValidator from "../../middleware/params/facility_id_validator.js";
import Court from "../../models/court.js";

const playerFacilityRouter = express.Router();

// Get all facilities route
playerFacilityRouter.get(
  "/player/facilities",
  playerValidator,
  sortValidator,
  async (req, res) => {
    try {
      let facilities = await Facility.find();

      const { province } = req.query;
      if (province) {
        facilities = facilities.filter(
          (facility) => facility.province === province
        );
      }

      // Sort
      const { sort, order } = req.query;

      if (sort === "location") {
        const { lat, lon } = req.query;
        facilities.sort((a, b) => {
          const distanceA = Math.sqrt(
            Math.pow(a.latitude - lat, 2) + Math.pow(a.longitude - lon, 2)
          );
          const distanceB = Math.sqrt(
            Math.pow(b.latitude - lat, 2) + Math.pow(b.longitude - lon, 2)
          );

          if (order === "asc") {
            return distanceA - distanceB;
          } else {
            return distanceB - distanceA;
          }
        });
      } else if (sort === "registered_at") {
        facilities.sort((a, b) => {
          if (order === "asc") {
            return a.registered_at - b.registered_at;
          } else {
            return b.registered_at - a.registered_at;
          }
        });
      }

      res.json(facilities);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get facility price range
playerFacilityRouter.get(
  "/player/facilities/price-range/:facility_id",
  playerValidator,
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

// Get all provinces
playerFacilityRouter.get(
  "/player/facilities/provinces",
  playerValidator,
  async (req, res) => {
    try {
      const facilities = await Facility.find();

      const provinces = facilities.map((facility) => facility.province);
      const uniqueProvinces = [...new Set(provinces)];

      res.json(uniqueProvinces);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default playerFacilityRouter;
