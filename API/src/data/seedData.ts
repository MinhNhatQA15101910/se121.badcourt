import mongoose from "mongoose";
import User from "../models/user";
import { facilityData, userData } from "./data";
import { hashSync } from "bcrypt";
import {
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_CLOUD_NAME,
  SALT_ROUNDS,
} from "../secrets";
import { v2 as cloudinary } from "cloudinary";
import Facility from "../models/facility";

cloudinary.config({
  cloud_name: CLOUDINARY_CLOUD_NAME,
  api_key: CLOUDINARY_API_KEY,
  api_secret: CLOUDINARY_API_SECRET,
});

export const seedData = async () => {
  try {
    await seedUsers();
    await seedFacilities();
  } catch (error) {
    console.error("Error seeding data:", error);
    mongoose.connection.close();
  }
};

const seedUsers = async () => {
  const users = await User.find();
  if (users.length === 0) {
    let index = 1;
    for (let user of userData) {
      user.password = hashSync("Pa$$w0rd", +SALT_ROUNDS);
      let newUser = new User(user);
      newUser = await newUser.save();

      const result = await cloudinary.uploader.upload(
        `src/data/resources/users/${index++}.jpg`,
        {
          folder: `BadCourt-prod/users/${newUser._id}`,
          resource_type: "image",
        }
      );

      newUser.image = {
        url: result.url,
        publicId: result.public_id,
        isMain: true,
        type: "image",
      };
      await newUser.save();
    }
    console.log("Users seeded successfully");
  }
};

const seedFacilities = async () => {
  const facilities = await Facility.find();
  if (facilities.length === 0) {
    const users = await User.find();
    let index = 1;
    for (let facility of facilityData) {
      let newFacility = new Facility(facility);
      newFacility.userId = users[index + 1]._id.toString();
      newFacility = await newFacility.save();

      let managerInfo = newFacility.managerInfo;

      // Upload facility images
      for (let i = 1; i <= 5; i++) {
        let result = await cloudinary.uploader.upload(
          `src/data/resources/facilities/${index}/${i}.jpg`,
          {
            folder: `BadCourt-prod/facilities/${newFacility._id}/facility_images`,
            resource_type: "image",
          }
        );

        newFacility.facilityImages.push({
          url: result.url,
          publicId: result.public_id,
          isMain: i === 1,
          type: "image",
        });
      }

      // Upload citizen image front
      let result = await cloudinary.uploader.upload(
        `src/data/resources/facilities/citizen_images/1.jpg`,
        {
          folder: `BadCourt-prod/facilities/${newFacility._id}/citizen_images`,
          resource_type: "image",
        }
      );
      managerInfo!.citizenImageFront = {
        url: result.url,
        publicId: result.public_id,
        isMain: true,
        type: "image",
      };

      // Upload citizen image back
      result = await cloudinary.uploader.upload(
        `src/data/resources/facilities/citizen_images/2.jpg`,
        {
          folder: `BadCourt-prod/facilities/${newFacility._id}/citizen_images`,
          resource_type: "image",
        }
      );
      managerInfo!.citizenImageBack = {
        url: result.url,
        publicId: result.public_id,
        isMain: true,
        type: "image",
      };

      // Upload bank card image front
      result = await cloudinary.uploader.upload(
        `src/data/resources/facilities/bank_card_images/1.jpg`,
        {
          folder: `BadCourt-prod/facilities/${newFacility._id}/bank_card_images`,
          resource_type: "image",
        }
      );
      managerInfo!.bankCardFront = {
        url: result.url,
        publicId: result.public_id,
        isMain: true,
        type: "image",
      };

      // Upload bank card image back
      result = await cloudinary.uploader.upload(
        `src/data/resources/facilities/bank_card_images/2.jpg`,
        {
          folder: `BadCourt-prod/facilities/${newFacility._id}/bank_card_images`,
          resource_type: "image",
        }
      );
      managerInfo!.bankCardBack = {
        url: result.url,
        publicId: result.public_id,
        isMain: true,
        type: "image",
      };

      // Upload business license images
      for (let i = 1; i <= 10; i++) {
        let result = await cloudinary.uploader.upload(
          `src/data/resources/facilities/business_license_images/${i}.jpg`,
          {
            folder: `BadCourt-prod/facilities/${newFacility._id}/business_license_images`,
            resource_type: "image",
          }
        );

        managerInfo!.businessLicenseImages.push({
          url: result.url,
          publicId: result.public_id,
          isMain: i === 1,
          type: "image",
        });
      }

      newFacility.managerInfo = managerInfo;
      await newFacility.save();

      index++;
    }
    console.log("Facilities seeded successfully");
  }
};
