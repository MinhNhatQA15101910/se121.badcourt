// Packages
import express from "express";

// Header middleware
import playerValidator from "../../middleware/header/player_validator.js";

// Params middleware
import courtIdValidator from "../../middleware/params/court_id_validator.js";
import orderPeriodsValidator from "../../middleware/body/order_periods_validator.js";

// Models
import Court from "../../models/court.js";
import Facility from "../../models/facility.js";
import Order from "../../models/order.js";

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

      // Create new orders
      for (let i = 0; i < order_periods.length; i++) {
        let courtPricePerHour = court.price_per_hour;
        let orderedPeriodRange =
          order_periods[i].hour_to - order_periods[i].hour_from;
        let price = (orderedPeriodRange * courtPricePerHour) / 3600000;

        let facility = await Facility.findById(court.facility_id);

        let order = new Order({
          user_id: req.user,
          court_id,
          ordered_at: Date.now(),
          facility_name: facility.name,
          address: facility.detail_address,
          image_url: facility.image_urls[0],
          period: order_periods[i],
          price,
        });
        order = await order.save();
      }

      // Add order periods
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
    (timePeriod1.hour_to >= timePeriod2.hour_from &&
      timePeriod1.hour_to <= timePeriod2.hour_to) ||
    (timePeriod2.hour_to >= timePeriod1.hour_from &&
      timePeriod2.hour_to <= timePeriod1.hour_to)
  );
}

export default playerCourtRouter;
