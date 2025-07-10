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
    IUserApiRepository userApiRepository,
    IStripeService stripeService
) : ICommandHandler<CreateOrderCommand, OrderIntentDto>
{
    public async Task<OrderIntentDto> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        // Convert HourFrom and HourTo from user-local time to UTC
        var timeZoneId = request.CreateOrderDto.TimeZoneId;
        DateTime hourFromUtc = ConvertToUtc(request.CreateOrderDto.DateTimePeriod.HourFrom, timeZoneId);
        DateTime hourToUtc = ConvertToUtc(request.CreateOrderDto.DateTimePeriod.HourTo, timeZoneId);
        var newOrderDateTimePeriodDto = new DateTimePeriodDto
        {
            HourFrom = hourFromUtc,
            HourTo = hourToUtc
        };

        var court = await courtApiRepository.GetCourtByIdAsync(request.CreateOrderDto.CourtId)
            ?? throw new CourtNotFoundException(request.CreateOrderDto.CourtId);

        if (court.UserState == "Locked") throw new CourtLockedException(court.Id);

        var facility = await facilityApiRepository.GetFacilityByIdAsync(court.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(court.FacilityId);

        // Check if the DateTimePeriod is in the future
        if (hourFromUtc < DateTime.UtcNow)
        {
            throw new BadRequestException("The start date must be in the future.");
        }

        // Check if the DateTimePeriod HourFrom and HourTo are in the same day
        if (hourFromUtc.Date != hourToUtc.Date)
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
        var orderDate = hourFromUtc.Date.DayOfWeek.ToString();

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
            HourFrom = TimeOnly.FromTimeSpan(hourFromUtc.TimeOfDay),
            HourTo = TimeOnly.FromTimeSpan(hourToUtc.TimeOfDay)
        };
        if (!IsTimePeriodInside(newOrderTimePeriod, (TimePeriodDto)isActive))
        {
            throw new BadRequestException("The order time period is outside the facility's active hours.");
        }

        // Check if the order time period is overlapping with existing orders
        foreach (var orderTimePeriod in court.OrderPeriods)
        {
            if (IsTimePeriodOverlapping(newOrderDateTimePeriodDto, orderTimePeriod))
            {
                throw new BadRequestException("The order time period overlaps with an existing order.");
            }
        }

        // Check if the order time period is overlapping with the court's inactive hours
        foreach (var inactiveTimePeriod in court.InactivePeriods)
        {
            if (IsTimePeriodOverlapping(newOrderDateTimePeriodDto, inactiveTimePeriod))
            {
                throw new BadRequestException("The order time period overlaps with the court's inactive hours.");
            }
        }

        // Calculate price
        var price = court.PricePerHour * (decimal)(hourToUtc - hourFromUtc).TotalHours;

        // Create PaymentIntent via StripeService
        var paymentIntent = await stripeService.CreatePaymentIntentAsync(
            (long)price,
            cancellationToken: cancellationToken
        );

        // Create order
        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        var user = await userApiRepository.GetUserByIdAsync(userId.ToString(), cancellationToken)
            ?? throw new UserNotFoundException(userId);
        var facilityOwner = await userApiRepository.GetUserByIdAsync(facility.UserId.ToString(), cancellationToken)
            ?? throw new UserNotFoundException(facility.UserId);

        var facilityMainPhoto = facility.Photos.FirstOrDefault(p => p.IsMain);
        var draftOrder = new Order
        {
            UserId = userId,
            Username = user.Username,
            UserImageUrl = user.Photos.FirstOrDefault(p => p.IsMain)?.Url,
            FacilityOwnerId = facility.UserId.ToString(),
            FacilityOwnerUsername = facilityOwner.Username,
            FacilityOwnerImageUrl = facilityOwner.PhotoUrl,
            FacilityId = court.FacilityId,
            CourtId = request.CreateOrderDto.CourtId,
            CourtName = court.CourtName,
            FacilityName = facility.FacilityName,
            Province = facility.Province,
            Address = facility.DetailAddress,
            DateTimePeriod = new DateTimePeriod
            {
                HourFrom = hourFromUtc,
                HourTo = hourToUtc
            },
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

        Console.WriteLine(paymentIntent.Id);

        return new OrderIntentDto
        {
            ClientSecret = paymentIntent.ClientSecret,
            OrderId = draftOrder.Id.ToString()
        };
    }

    private static bool IsTimePeriodInside(TimePeriodDto inner, TimePeriodDto outer)
    {
        bool crossesMidnight = outer.HourFrom > outer.HourTo;

        static int ToShiftedMinutes(TimeOnly time, TimeOnly reference, bool crossesMidnight)
        {
            int minutes = time.Hour * 60 + time.Minute;
            int referenceMinutes = reference.Hour * 60 + reference.Minute;
            return crossesMidnight && minutes < referenceMinutes
                ? minutes + 24 * 60
                : minutes;
        }

        var outerFromMinutes = ToShiftedMinutes(outer.HourFrom, outer.HourFrom, false);
        var outerToMinutes = ToShiftedMinutes(outer.HourTo, outer.HourFrom, crossesMidnight);

        var innerFromMinutes = ToShiftedMinutes(inner.HourFrom, outer.HourFrom, crossesMidnight);
        var innerToMinutes = ToShiftedMinutes(inner.HourTo, outer.HourFrom, crossesMidnight);

        return innerFromMinutes >= outerFromMinutes && innerToMinutes <= outerToMinutes;
    }

    private static bool IsTimePeriodOverlapping(DateTimePeriodDto period1, DateTimePeriodDto period2)
    {
        return period1.HourFrom < period2.HourTo && period2.HourFrom < period1.HourTo;
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
