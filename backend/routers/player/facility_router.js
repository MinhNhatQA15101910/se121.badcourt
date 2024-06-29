// Packages
import express from "express";

// Models
import Facility from "../../models/facility.js";

// Header middleware
import playerValidator from "../../middleware/header/player_validator.js";

const playerFacilityRouter = express.Router();

// Get all facilities route
playerFacilityRouter.get(
  "/player/facilities",
  playerValidator,
  async (req, res) => {
    try {
      const facilities = await Facility.find();
      console.log(facilities);
      res.json(facilities);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default playerFacilityRouter;
