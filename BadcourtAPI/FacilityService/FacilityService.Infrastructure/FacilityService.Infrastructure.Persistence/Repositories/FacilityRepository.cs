using AutoMapper;
using FacilityService.Core.Domain.Entities;
using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using FacilityService.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Driver;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace FacilityService.Infrastructure.Persistence.Repositories;

public class FacilityRepository : IFacilityRepository
{
    private readonly IMongoCollection<Facility> _facilities;
    private readonly IMapper _mapper;

    public FacilityRepository(
        IOptions<FacilityDatabaseSettings> facilityDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(facilityDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(facilityDatabaseSettings.Value.DatabaseName);
        _facilities = mongoDatabase.GetCollection<Facility>(facilityDatabaseSettings.Value.FacilitiesCollectionName);

        _ = EnsureIndexesAsync(); // Fire and forget to avoid blocking constructor

        _mapper = mapper;
    }

    private async Task EnsureIndexesAsync()
    {
        var indexKeys = Builders<Facility>.IndexKeys.Geo2DSphere(f => f.Location);
        var indexModel = new CreateIndexModel<Facility>(indexKeys);
        await _facilities.Indexes.CreateOneAsync(indexModel);
    }

    public async Task AddFacilityAsync(Facility facility, CancellationToken cancellationToken = default)
    {
        await _facilities.InsertOneAsync(facility, cancellationToken: cancellationToken);
    }

    public async Task<bool> AnyAsync(CancellationToken cancellationToken = default)
    {
        return await _facilities.Find(_ => true).AnyAsync(cancellationToken);
    }

    public async Task<PagedList<FacilityDto>> GetFacilitiesAsync(FacilityParams facilityParams, CancellationToken cancellationToken = default)
    {
        var pipeline = new List<BsonDocument>();

        switch (facilityParams.OrderBy)
        {
            case "location":
                pipeline.Add(new BsonDocument("$geoNear", new BsonDocument
                {
                    { "near", new BsonDocument("type", "Point").Add("coordinates", new BsonArray { facilityParams.Lon, facilityParams.Lat }) },
                    { "distanceField", "Distance" },
                    { "spherical", true },
                }));
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("Distance", facilityParams.SortBy == "asc" ? 1 : -1)));
                break;
            case "price":
                pipeline.Add(new BsonDocument("$addFields", new BsonDocument("AvgPrice",
                    new BsonDocument("$avg", new BsonArray
                    {
                        new BsonDocument("$ifNull", new BsonArray { "$MinPrice", 0 }),
                        new BsonDocument("$ifNull", new BsonArray { "$MaxPrice", 0 })
                    }))));
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("AvgPrice", facilityParams.SortBy == "asc" ? 1 : -1)));
                break;
            case "state":
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("State", facilityParams.SortBy == "asc" ? 1 : -1)));
                break;
            case "registeredAt":
            default:
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("RegisteredAt", facilityParams.SortBy == "asc" ? 1 : -1)));
                break;
        }

        // Excluding locked facilities
        pipeline.Add(new("$match", new BsonDocument("UserState", new BsonDocument("$ne", "Locked"))));

        // Filter by user id
        if (!string.IsNullOrEmpty(facilityParams.UserId))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("UserId", facilityParams.UserId)));
        }

        // Filter by facility name
        if (!string.IsNullOrEmpty(facilityParams.FacilityName))
        {
            pipeline.Add(
                new BsonDocument(
                    "$match",
                    new BsonDocument(
                        "FacilityName",
                        new BsonDocument(
                            "$regex",
                            facilityParams.FacilityName).Add("$options", "i")
                        )
                    )
                );
        }

        // Filter by province
        if (!string.IsNullOrEmpty(facilityParams.Province))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("Province", facilityParams.Province)));
        }

        // Filter by state ignore case
        if (!string.IsNullOrEmpty(facilityParams.State))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("State", new BsonDocument("$regex", facilityParams.State).Add("$options", "i"))));
        }

        // Filter by search term
        if (!string.IsNullOrEmpty(facilityParams.Search))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument
            {
                { "$or", new BsonArray
                    {
                        new BsonDocument("FacilityName", new BsonDocument("$regex", facilityParams.Search).Add("$options", "i")),
                        new BsonDocument("Description", new BsonDocument("$regex", facilityParams.Search).Add("$options", "i"))
                    }
                }
            }));
        }

        // Filter by price range
        pipeline.Add(new BsonDocument("$match", new BsonDocument
        {
            { "MinPrice", new BsonDocument("$gte", facilityParams.MinPrice) },
            { "MaxPrice", new BsonDocument("$lte", facilityParams.MaxPrice) }
        }));

        var facilities = await PagedList<Facility>.CreateAsync(
            _facilities,
            pipeline,
            facilityParams.PageNumber,
            facilityParams.PageSize,
            cancellationToken
        );

        return PagedList<FacilityDto>.Map(facilities, _mapper);
    }

    public async Task<Facility?> GetFacilityByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        return await _facilities.Find(facility => facility.Id == id)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public Task<List<string>> GetFacilityProvincesAsync(CancellationToken cancellationToken)
    {
        var filter = Builders<Facility>.Filter.Ne(f => f.UserState, UserState.Locked);

        var distinctProvinces = _facilities.Distinct<string>("Province", filter, cancellationToken: cancellationToken);
        return distinctProvinces.ToListAsync(cancellationToken);
    }

    public async Task UpdateFacilityAsync(Facility facility, CancellationToken cancellationToken = default)
    {
        await _facilities.ReplaceOneAsync(
            f => f.Id == facility.Id,
            facility,
            cancellationToken: cancellationToken
        );
    }

    public async Task DeleteFacilityAsync(Facility facility, CancellationToken cancellationToken = default)
    {
        await _facilities.DeleteOneAsync(
            f => f.Id == facility.Id,
            cancellationToken: cancellationToken
        );
    }

    public Task<List<Facility>> GetAllFacilitiesAsync(FacilityParams facilityParams, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Facility>.Filter.Empty;

        // Filter by user id
        if (!string.IsNullOrEmpty(facilityParams.UserId))
        {
            filter &= Builders<Facility>.Filter.Eq(f => f.UserId, Guid.Parse(facilityParams.UserId));
        }

        // Filter by facility name
        if (!string.IsNullOrEmpty(facilityParams.FacilityName))
        {
            filter &= Builders<Facility>.Filter.Regex(f => f.FacilityName, new BsonRegularExpression(facilityParams.FacilityName, "i"));
        }

        // Filter by province
        if (!string.IsNullOrEmpty(facilityParams.Province))
        {
            filter &= Builders<Facility>.Filter.Eq(f => f.Province, facilityParams.Province);
        }

        // Filter by state ignore case
        if (!string.IsNullOrEmpty(facilityParams.State))
        {
            filter &= Builders<Facility>.Filter.Regex(f => f.State, new BsonRegularExpression(facilityParams.State, "i"));
        }

        // Filter by search term
        if (!string.IsNullOrEmpty(facilityParams.Search))
        {
            filter &= Builders<Facility>.Filter.Or(
                Builders<Facility>.Filter.Regex(f => f.FacilityName, new BsonRegularExpression(facilityParams.Search, "i")),
                Builders<Facility>.Filter.Regex(f => f.Description, new BsonRegularExpression(facilityParams.Search, "i"))
            );
        }

        // Filter by price range
        filter &= Builders<Facility>.Filter.And(
            Builders<Facility>.Filter.Gte(f => f.MinPrice, facilityParams.MinPrice),
            Builders<Facility>.Filter.Lte(f => f.MaxPrice, facilityParams.MaxPrice)
        );

        return _facilities.Find(filter)
            .ToListAsync(cancellationToken);
    }
}
