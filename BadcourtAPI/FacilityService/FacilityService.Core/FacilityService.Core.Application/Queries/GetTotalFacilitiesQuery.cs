namespace FacilityService.Core.Application.Queries;

public record GetTotalFacilitiesQuery(int? Year) : IQuery<int>;
