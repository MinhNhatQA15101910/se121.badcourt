// Validate image urls
const facilityImageUrlsValidator = async (req, res, next) => {
  console.log("Facility image urls validator middleware:");
  console.log("- Facility image urls: " + req.body.facility_image_urls);
  try {
    const imageUrls = req.body.facility_image_urls;

    if (!imageUrls) {
      return res.status(400).json({ msg: "Facility image urls is required." });
    }

    if (imageUrls.length === 0) {
      return res
        .status(400)
        .json({ msg: "Facility image urls must not be an empty list." });
    }

    for (let i = 0; i < imageUrls.length; i++) {
      if (!imageUrls[i]) {
        return res.status(400).json({ msg: "Invalid facility image urls." });
      }
    }

    if (new Set(imageUrls).size !== imageUrls.length) {
      return res
        .status(400)
        .json({ msg: "Facility image urls cannot be duplicated." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default facilityImageUrlsValidator;
