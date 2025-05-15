using SharedKernel.DTOs;

namespace OrderService.Core.Application.Commands.CreateOrder;

public class CreateOrderDto
{
    public string CourtId { get; set; } = null!;
    public DateTimePeriodDto DateTimePeriod { get; set; } = null!;
}
