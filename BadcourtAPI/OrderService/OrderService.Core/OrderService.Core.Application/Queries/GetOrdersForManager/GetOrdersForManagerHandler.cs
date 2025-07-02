using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetOrdersForManager;

public class GetOrdersForManagerHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetOrdersForManagerQuery, PagedList<OrderDto>>
{
    public async Task<PagedList<OrderDto>> Handle(GetOrdersForManagerQuery request, CancellationToken cancellationToken)
    {
        // Convert HourFrom and HourTo to UTC DateTime if they are not already
        request.OrderParams.HourFrom = ConvertToUtc(request.OrderParams.HourFrom, request.OrderParams.TimeZoneId);
        request.OrderParams.HourTo = ConvertToUtc(request.OrderParams.HourTo, request.OrderParams.TimeZoneId);

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return await orderRepository.GetOrdersForManagerAsync(
            request.OrderParams,
            userId,
            cancellationToken
        );
    }

    private static DateTime ConvertToUtc(DateTime localDateTime, string timeZoneId)
    {
        var timeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

        if (localDateTime.Kind == DateTimeKind.Utc)
            return localDateTime;

        var unspecified = DateTime.SpecifyKind(localDateTime, DateTimeKind.Unspecified);
        return TimeZoneInfo.ConvertTimeToUtc(unspecified, timeZone);
    }
}
