using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace SharedKernel;

public class PagedListConverter<T> : JsonConverter<PagedList<T>>
{
    public override void WriteJson(JsonWriter writer, PagedList<T>? value, JsonSerializer serializer)
    {
        var obj = new JObject
        {
            ["CurrentPage"] = value?.CurrentPage,
            ["TotalPages"] = value?.TotalPages,
            ["PageSize"] = value?.PageSize,
            ["TotalCount"] = value?.TotalCount,
            ["Items"] = JArray.FromObject(value!.ToList(), serializer)
        };

        obj.WriteTo(writer);
    }

    public override PagedList<T> ReadJson(JsonReader reader, Type objectType, PagedList<T>? existingValue, bool hasExistingValue, JsonSerializer serializer)
    {
        var obj = JObject.Load(reader);

        var items = obj["Items"]?.ToObject<List<T>>(serializer) ?? new List<T>();
        var currentPage = obj["CurrentPage"]?.Value<int>() ?? 1;
        var totalPages = obj["TotalPages"]?.Value<int>() ?? 1;
        var pageSize = obj["PageSize"]?.Value<int>() ?? 10;
        var totalCount = obj["TotalCount"]?.Value<int>() ?? items.Count;

        return new PagedList<T>(items, totalCount, currentPage, pageSize);
    }
}
