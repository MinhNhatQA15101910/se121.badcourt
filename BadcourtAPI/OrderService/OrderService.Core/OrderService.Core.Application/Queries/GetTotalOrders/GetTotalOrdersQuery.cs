namespace OrderService.Core.Application.Queries.GetTotalOrders;

public record GetTotalOrdersQuery(int? Year) : IQuery<int>;
