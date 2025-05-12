using SharedKernel.DTOs;

namespace OrderService.Core.Application.Commands.CreateOrder;

public class CreateOrderDto
{
    public Guid UserId { get; set; }
    public string CourtId { get; set; } = null!;
    public DateTimePeriodDto DateTimePeriod { get; set; } = null!;
}
