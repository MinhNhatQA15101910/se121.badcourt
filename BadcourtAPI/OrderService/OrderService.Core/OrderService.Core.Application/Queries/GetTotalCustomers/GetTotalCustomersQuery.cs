namespace OrderService.Core.Application.Queries.GetTotalCustomers;

public record GetTotalCustomersQuery(int? Year) : IQuery<int>;
