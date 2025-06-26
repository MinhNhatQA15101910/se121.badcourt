using AutoMapper;
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Application.Interfaces;
using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Enums;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Commands.CreateOrder;

public class CreateOrderHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository,
    ICourtApiRepository courtApiRepository,
    IFacilityApiRepository facilityApiRepository,
    IStripeService stripeService,
    IMapper mapper
) : ICommandHandler<CreateOrderCommand, OrderIntentDto>
{
    public async Task<OrderIntentDto> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        var court = await courtApiRepository.GetCourtByIdAsync(request.CreateOrderDto.CourtId)
            ?? throw new CourtNotFoundException(request.CreateOrderDto.CourtId);

        var facility = await facilityApiRepository.GetFacilityByIdAsync(court.FacilityId)
            ?? throw new FacilityNotFoundException(court.FacilityId);

        // Check if the DateTimePeriod is in the future
        if (request.CreateOrderDto.DateTimePeriod.HourFrom < DateTime.UtcNow)
        {
            throw new BadRequestException("The start date must be in the future.");
        }

        // Check if the DateTimePeriod HourFrom and HourTo are in the same day
        if (request.CreateOrderDto.DateTimePeriod.HourFrom.Date != request.CreateOrderDto.DateTimePeriod.HourTo.Date)
        {
            throw new BadRequestException("The start and end date must be in the same day.");
        }

        // Check if the facility's active is null
        if (facility.ActiveAt == null)
        {
            throw new BadRequestException("The facility's active date is null.");
        }

        // Check if the DateTimePeriod date is the facility's active date
        /// Get the order date's day in week
        var orderDate = request.CreateOrderDto.DateTimePeriod.HourFrom.Date.DayOfWeek.ToString();

        /// Check if facility.ActiveAt.orderDate is not null
        var activeDays = new Dictionary<string, object?>
        {
            { "Monday", facility.ActiveAt.Monday },
            { "Tuesday", facility.ActiveAt.Tuesday },
            { "Wednesday", facility.ActiveAt.Wednesday },
            { "Thursday", facility.ActiveAt.Thursday },
            { "Friday", facility.ActiveAt.Friday },
            { "Saturday", facility.ActiveAt.Saturday },
            { "Sunday", facility.ActiveAt.Sunday }
        };

        if (!activeDays.TryGetValue(orderDate, out var isActive) || isActive == null)
        {
            throw new BadRequestException("The facility is not active on this day.");
        }

        // Convert DateTimePeriod to TimePeriodDto
        var newOrderTimePeriod = new TimePeriodDto
        {
            HourFrom = TimeOnly.FromTimeSpan(request.CreateOrderDto.DateTimePeriod.HourFrom.TimeOfDay),
            HourTo = TimeOnly.FromTimeSpan(request.CreateOrderDto.DateTimePeriod.HourTo.TimeOfDay)
        };
        if (!IsTimePeriodInside(newOrderTimePeriod, (TimePeriodDto)isActive))
        {
            throw new BadRequestException("The order time period is outside the facility's active hours.");
        }

        // Check if the order time period is overlapping with existing orders
        foreach (var orderTimePeriod in court.OrderPeriods)
        {
            if (IsTimePeriodOverlapping(request.CreateOrderDto.DateTimePeriod, orderTimePeriod))
            {
                throw new BadRequestException("The order time period overlaps with an existing order.");
            }
        }

        // Check if the order time period is overlapping with the court's inactive hours
        foreach (var inactiveTimePeriod in court.InactivePeriods)
        {
            if (IsTimePeriodOverlapping(request.CreateOrderDto.DateTimePeriod, inactiveTimePeriod))
            {
                throw new BadRequestException("The order time period overlaps with the court's inactive hours.");
            }
        }

        // Calculate price
        var price = court.PricePerHour * (decimal)(request.CreateOrderDto.DateTimePeriod.HourTo - request.CreateOrderDto.DateTimePeriod.HourFrom).TotalHours;

        // Create PaymentIntent via StripeService
        var paymentIntent = await stripeService.CreatePaymentIntentAsync(
            (long)price,
            cancellationToken: cancellationToken
        );

        // Create order
        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        var facilityMainPhoto = facility.Photos.FirstOrDefault(p => p.IsMain);
        var draftOrder = new Order
        {
            UserId = userId,
            FacilityOwnerId = facility.UserId.ToString(),
            FacilityId = court.FacilityId,
            CourtId = request.CreateOrderDto.CourtId,
            FacilityName = facility.FacilityName,
            Address = facility.DetailAddress,
            DateTimePeriod = mapper.Map<DateTimePeriod>(request.CreateOrderDto.DateTimePeriod),
            Price = price,
            ImageUrl = facilityMainPhoto?.Url ?? string.Empty,
            PaymentIntentId = paymentIntent.Id,
            State = OrderState.Pending
        };

        orderRepository.AddOrder(draftOrder);

        if (!await orderRepository.CompleteAsync(cancellationToken))
        {
            throw new BadRequestException("Failed to create order.");
        }

        return new OrderIntentDto
        {
            ClientSecret = paymentIntent.ClientSecret,
            OrderId = draftOrder.Id.ToString()
        };
    }

    private static bool IsTimePeriodInside(TimePeriodDto inner, TimePeriodDto outer)
    {
        return inner.HourFrom >= outer.HourFrom && inner.HourTo <= outer.HourTo;
    }

    private static bool IsTimePeriodOverlapping(DateTimePeriodDto period1, DateTimePeriodDto period2)
    {
        return period1.HourFrom < period2.HourTo && period2.HourFrom < period1.HourTo;
    }
}
