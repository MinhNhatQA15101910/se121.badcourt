const sortOptions = ["location", "registered_at", "price"];
const orderOptions = ["asc", "desc"];

// Validate sort
const sortValidator = (req, res, next) => {
  console.log("Sort validator middleware:");
  console.log(`- Sort: ${req.query.sort}`);
  console.log(`- Order: ${req.query.order}`);

  try {
    let { sort, order } = req.query;

    if (sort || order) {
      if (!sortOptions.includes(sort)) {
        return res.status(400).json({ msg: "Invalid sort attribute." });
      }

      if (!orderOptions.includes(order)) {
        return res.status(400).json({ msg: "Invalid order option." });
      }

      if (sort === "location") {
        const { lat, lon } = req.query;
        if (!lat || !lon) {
          return res
            .status(400)
            .json({ msg: "Latitude and longitude are required." });
        }
      }
    } else {
      req.query.sort = "registered_at";
      req.query.order = "asc";
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default sortValidator;
