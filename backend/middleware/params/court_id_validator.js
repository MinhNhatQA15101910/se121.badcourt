import Court from "../../models/court.js";

const courtIdValidator = async (req, res, next) => {
  console.log("Court id validator middleware:");
  console.log("- Court id: " + req.params.court_id);

  try {
    const courtId = req.params.court_id;

    if (!courtId) {
      return res.status(400).json({ msg: "Court id is required." });
    }

    const court = await Court.findById(courtId);
    if (!court) {
      return res.status(400).json({ msg: "Court not exist." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default courtIdValidator;
