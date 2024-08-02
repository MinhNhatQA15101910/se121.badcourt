// Validate business license image urls
const businessLicenseImageUrlsValidator = async (req, res, next) => {
  console.log("Business license image urls validator middleware:");
  console.log("- Image urls: " + req.body.business_license_image_urls);
  try {
    const imageUrls = req.body.business_license_image_urls;

    if (!imageUrls) {
      return res
        .status(400)
        .json({ msg: "Business license image urls is required." });
    }

    if (imageUrls.length === 0) {
      return res.status(400).json({
        msg: "Business license image urls must not be an empty list.",
      });
    }

    for (let i = 0; i < imageUrls.length; i++) {
      if (!imageUrls[i]) {
        return res
          .status(400)
          .json({ msg: "Invalid business license image urls." });
      }
    }

    if (new Set(imageUrls).size !== imageUrls.length) {
      return res
        .status(400)
        .json({ msg: "Business license image urls cannot be duplicated." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default businessLicenseImageUrlsValidator;
