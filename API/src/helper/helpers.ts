import { FileDto } from "../dtos/file.dto";
import { IFileService } from "../interfaces/services/IFile.service";
import { Response } from "express";
import { PagedList } from "./pagedList";
import { PaginationHeader } from "./paginationHeader";

export const uploadImages = async (
  fileService: IFileService,
  files: any,
  folderName: string
): Promise<FileDto[]> => {
  const images = [];
  let isMain = true;
  for (const file of files) {
    const result = await fileService.uploadFile(file.path, folderName, "image");
    images.push({
      url: result.url,
      publicId: result.public_id,
      isMain,
      type: "image",
    });

    isMain = false;
  }

  return images;
};

export const addPaginationHeader = function <T>(
  res: Response,
  data: PagedList<T>
) {
  const paginationHeader = new PaginationHeader(
    data.currentPage,
    data.pageSize,
    data.totalCount,
    data.totalPages
  );

  res.setHeader("Pagination", JSON.stringify(paginationHeader));
  res.setHeader("Access-Control-Expose-Headers", "Pagination");
};
