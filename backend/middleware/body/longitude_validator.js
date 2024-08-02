// Validate longitude
const longitudeValidator = (req, res, next) => {
  console.log("Longitude validator middleware:");
  console.log("- Longitude: " + req.body.lon);

  try {
    const lon = req.body.lon;

    if (!lon) {
      return res.status(400).json({ msg: "Longitude is required." });
    }

    if (!isFinite(lon) || Math.abs(lon) > 180) {
      return res.status(400).json({ msg: "Invalid Longitude." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default longitudeValidator;
