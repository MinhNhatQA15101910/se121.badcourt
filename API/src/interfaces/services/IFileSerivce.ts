import { UploadApiResponse } from "cloudinary";

export interface IFileService {
  addPhoto(filePath: string, folder: string): Promise<UploadApiResponse>;
  deleteFile(publicId: string): Promise<void>;
}
