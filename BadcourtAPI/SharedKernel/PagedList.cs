using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MongoDB.Bson;
using MongoDB.Driver;
using Newtonsoft.Json;

namespace SharedKernel;

[JsonObject]
public class PagedList<T> : List<T>
{
    public PagedList() { }

    public PagedList(IEnumerable<T> items, int count, int pageNumber, int pageSize)
    {
        CurrentPage = pageNumber;
        TotalPages = (int)Math.Ceiling(count / (double)pageSize);
        PageSize = pageSize;
        TotalCount = count;
        AddRange(items);
    }

    public int CurrentPage { get; set; }
    public int TotalPages { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
    public List<T> Items => [.. this];

    public static async Task<PagedList<T>> CreateAsync(
        IQueryable<T> source,
        int pageNumber,
        int pageSize
    )
    {
        var count = await source.CountAsync();
        var items = await source.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync();
        return new PagedList<T>(items, count, pageNumber, pageSize);
    }

    public static async Task<PagedList<T>> CreateAsync(
        IMongoCollection<T> collection,
        List<BsonDocument> pipeline,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default
    )
    {
        // Count total results before pagination
        var countPipeline = new List<BsonDocument>(pipeline) { new("$count", "count") };

        // Apply pagination: skip and limit
        var skip = (pageNumber - 1) * pageSize;
        pipeline.Add(new BsonDocument("$skip", skip));
        pipeline.Add(new BsonDocument("$limit", pageSize));

        var task = collection.Aggregate<T>(pipeline, cancellationToken: cancellationToken).ToListAsync(cancellationToken);
        var countTask = collection.Aggregate<BsonDocument>(countPipeline, cancellationToken: cancellationToken).FirstOrDefaultAsync(cancellationToken);

        await Task.WhenAll(task, countTask);

        var totalCount = countTask.Result?.GetValue("count", 0).ToInt32() ?? 0;

        return new PagedList<T>(task.Result, totalCount, pageNumber, pageSize);
    }

    public static PagedList<T> Map<TSource>(PagedList<TSource> source, IMapper mapper)
        where TSource : class
    {
        return new PagedList<T>(
            source.Select(mapper.Map<T>),
            source.TotalCount,
            source.CurrentPage,
            source.PageSize
        );
    }
}
