// Packages
import express from "express";

// Header middleware
import playerValidator from "../../middleware/header/player_validator.js";

// Params middleware
import courtIdValidator from "../../middleware/params/court_id_validator.js";
import Court from "../../models/court.js";
import orderPeriodsValidator from "../../middleware/body/order_periods_validator.js";

const playerCourtRouter = express.Router();

// Book court route
playerCourtRouter.patch(
  "/player/book-court/:court_id",
  playerValidator,
  courtIdValidator,
  orderPeriodsValidator,
  async (req, res) => {
    try {
      const { court_id } = req.params;
      const { order_periods } = req.body;

      let court = await Court.findById(court_id);

      // Check for collapse
      for (let i = 0; i < order_periods.length; i++) {
        for (let j = 0; j < court.order_periods.length; j++) {
          if (isCollapse(order_periods[i], court.order_periods[j])) {
            return res.status(400).json({ msg: "Collapse occurred." });
          }
        }
      }

      for (let i = 0; i < order_periods.length; i++) {
        order_periods[i].user_id = req.user;
      }

      court.order_periods.push(...order_periods);
      court = await court.save();

      res.json(court);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get courts route
playerCourtRouter.get("/player/courts", playerValidator, async (req, res) => {
  try {
    const { facility_id } = req.query;

    const courts = await Court.find({ facility_id });

    res.json(courts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

function isCollapse(timePeriod1, timePeriod2) {
  console.log(timePeriod1);
  console.log(timePeriod2);

  return (
    (timePeriod1.hour_to > timePeriod2.hour_from &&
      timePeriod1.hour_to < timePeriod2.hour_to) ||
    (timePeriod2.hour_to > timePeriod1.hour_from &&
      timePeriod2.hour_to < timePeriod1.hour_to)
  );
}

export default playerCourtRouter;
