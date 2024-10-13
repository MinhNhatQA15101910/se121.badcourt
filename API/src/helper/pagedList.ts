import { Query } from "mongoose";

export class PagedList<T> extends Array<T> {
  currentPage: number;
  totalPages: number;
  pageSize: number;
  totalCount: number;

  constructor(items: T[], count: number, pageNumber: number, pageSize: number) {
    super(...items);
    this.currentPage = pageNumber;
    this.totalPages = Math.ceil(count / pageSize);
    this.pageSize = pageSize;
    this.totalCount = count;
  }

  static async create<T>(
    query: Query<any[], any>,
    pageNumber: number,
    pageSize: number
  ): Promise<PagedList<T>> {
    const cloneQuery = query.clone();
    const count = await cloneQuery.countDocuments();

    const items = await query
      .skip((pageNumber - 1) * pageSize)
      .limit(pageSize)
      .exec();
    return new PagedList<T>(items, count, pageNumber, pageSize);
  }
}
