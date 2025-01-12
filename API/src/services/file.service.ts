import { v2 as cloudinary, ResourceType, UploadApiResponse } from "cloudinary";
import {
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_CLOUD_NAME,
} from "../secrets";
import { injectable } from "inversify";
import { IFileService } from "../interfaces/services/IFile.service";

cloudinary.config({
  cloud_name: CLOUDINARY_CLOUD_NAME,
  api_key: CLOUDINARY_API_KEY,
  api_secret: CLOUDINARY_API_SECRET,
});

@injectable()
export class FileService implements IFileService {
  async addPhoto(filePath: string, folder: string): Promise<UploadApiResponse> {
    const result = await cloudinary.uploader.upload(filePath, { folder });
    return result;
  }

  async deleteFile(publicId: string, resourceType: ResourceType): Promise<any> {
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType,
    });
    return result;
  }
}
