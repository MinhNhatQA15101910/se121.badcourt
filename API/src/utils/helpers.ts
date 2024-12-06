import { FileDto } from "../dtos/fileDto";
import { IFileService } from "../interfaces/services/IFileService";

export const uploadImages = async (
  fileService: IFileService,
  files: any,
  folderName: string
): Promise<FileDto[]> => {
  const images = [];
  let isMain = true;
  for (const file of files) {
    const result = await fileService.addPhoto(
      file.path,
      `BadCourt/${folderName}`
    );
    images.push({
      url: result.url,
      publicId: result.public_id,
      isMain,
    });

    isMain = false;
  }

  return images;
};
