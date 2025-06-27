namespace OrderService.Core.Application.Queries.GetTotalRevenue;

public record GetTotalRevenueQuery(int? Year) : IQuery<decimal>;
