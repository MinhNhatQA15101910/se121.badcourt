import Facility from "../../models/facility.js";

const facilityIdValidator = async (req, res, next) => {
  console.log("Facility id validator middleware:");
  console.log("- Facility id: " + req.params.facility_id);

  try {
    const facilityId = req.params.facility_id;

    if (!facilityId) {
      return res.status(400).json({ msg: "Facility id is required." });
    }

    const facility = await Facility.findById(facilityId);
    if (!facility) {
      return res.status(400).json({ msg: "Facility not exist." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default facilityIdValidator;
