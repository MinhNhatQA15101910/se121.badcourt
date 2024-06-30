// Validate active
const activeValidator = (req, res, next) => {
  console.log("Active validator middleware:");

  try {
    const active = req.body.active;

    if (!active) {
      return res.status(400).json({ msg: "Active information is required." });
    }

    const monday = active.monday;
    const tuesday = active.tuesday;
    const wednesday = active.wednesday;
    const thursday = active.thursday;
    const friday = active.friday;
    const saturday = active.saturday;
    const sunday = active.sunday;

    if (monday) {
      if (monday.hour_from >= monday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    if (tuesday) {
      if (tuesday.hour_from >= tuesday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    if (wednesday) {
      if (wednesday.hour_from >= wednesday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    if (thursday) {
      if (thursday.hour_from >= thursday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    if (friday) {
      if (friday.hour_from >= friday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    if (saturday) {
      if (saturday.hour_from >= saturday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    if (sunday) {
      if (sunday.hour_from >= sunday.hour_to) {
        return res.status(400).json({ msg: "Invalid active information" });
      }
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default activeValidator;
