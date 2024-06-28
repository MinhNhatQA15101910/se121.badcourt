// Validate latitude
const latitudeValidator = (req, res, next) => {
  console.log("Latitude validator middleware:");
  console.log("- Latitude: " + req.body.lat);

  try {
    const lat = req.body.lat;

    if (!lat) {
      return res.status(400).json({ msg: "Latitude is required." });
    }

    if (!isFinite(lat) || Math.abs(lat) > 90) {
      return res.status(400).json({ msg: "Invalid latitude." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default latitudeValidator;
