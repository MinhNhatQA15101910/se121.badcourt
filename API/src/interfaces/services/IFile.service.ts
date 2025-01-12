import { ResourceType, UploadApiResponse } from "cloudinary";

export interface IFileService {
  addPhoto(filePath: string, folder: string): Promise<UploadApiResponse>;
  deleteFile(publicId: string, resourceType: ResourceType): Promise<void>;
}
