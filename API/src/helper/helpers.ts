import { FileDto } from "../dtos/files/file.dto";
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

export const isIntersect = function (timePeriod1: any, timePeriod2: any) {
  return (
    timePeriod1.hourFrom < timePeriod2.hourTo &&
    timePeriod1.hourTo > timePeriod2.hourFrom
  );
};

export const isOverlap = function (
  outsideTimePeriod1: any,
  insideTimePeriod2: any
) {
  return (
    outsideTimePeriod1.hourFrom <= insideTimePeriod2.hourFrom &&
    outsideTimePeriod1.hourTo >= insideTimePeriod2.hourTo
  );
};
