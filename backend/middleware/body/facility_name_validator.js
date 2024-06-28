// Validate facility name
const facilityNameValidator = (req, res, next) => {
  console.log("Facility name validator middleware:");
  console.log("- Facility name: " + req.body.facility_name);

  try {
    const facilityName = req.body.facility_name;

    if (!facilityName) {
      return res.status(400).json({ msg: "Facility name is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default facilityNameValidator;
