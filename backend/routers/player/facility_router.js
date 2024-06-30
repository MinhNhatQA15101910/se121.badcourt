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
      facilities = facilities.filter(
        (facility) => facility.province === province
      );

      // Sort
      const { sort, order } = req.query;

      if (sort === "location") {
        const { lat, lon } = req.body;
        facilities.sort((a, b) => {
          const distanceA = Math.sqrt(
            Math.pow(a.lat - lat, 2) + Math.pow(a.lon - lon, 2)
          );
          const distanceB = Math.sqrt(
            Math.pow(b.lat - lat, 2) + Math.pow(b.lon - lon, 2)
          );

          if (order === "asc") {
            return distanceA - distanceB;
          } else {
            return distanceB - distanceA;
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

export default playerFacilityRouter;
