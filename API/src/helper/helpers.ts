import { FileDto } from "../dtos/fileDto";
import { IFileService } from "../interfaces/services/IFileService";
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
