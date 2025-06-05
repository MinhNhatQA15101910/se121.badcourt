using SharedKernel.DTOs;

namespace SharedKernel.Events;

public record OrderCreatedEvent(string OrderId, string CourtId, string UserId, DateTimePeriodDto DateTimePeriodDto);
