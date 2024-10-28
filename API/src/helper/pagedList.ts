import { Aggregate, Query } from "mongoose";

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
    aggregate: Aggregate<any[]>,
    countAggregate: Aggregate<any[]>,
    pageNumber: number,
    pageSize: number
  ): Promise<PagedList<T>> {
    const count = (await countAggregate.exec())[0]?.count || 0;

    const items = await aggregate
      .skip((pageNumber - 1) * pageSize)
      .limit(pageSize)
      .exec();
    return new PagedList<T>(items, count, pageNumber, pageSize);
  }
}
