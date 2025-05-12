using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Commands.CreateOrder;

public class CreateOrderHandler(
    IOrderRepository orderRepository,
    ICourtApiRepository courtApiRepository,
    IFacilityApiRepository facilityApiRepository
) : ICommandHandler<CreateOrderCommand, OrderDto>
{
    public async Task<OrderDto> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
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
            throw new BadRequestException("The facility is not active on this day.");
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
    }
}
