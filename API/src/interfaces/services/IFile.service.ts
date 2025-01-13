import { ResourceType, UploadApiResponse } from "cloudinary";

export interface IFileService {
  uploadFile(
    filePath: string,
    folder: string,
    resourceType: ResourceType
  ): Promise<UploadApiResponse>;
  deleteFile(publicId: string, resourceType: ResourceType): Promise<void>;
}
