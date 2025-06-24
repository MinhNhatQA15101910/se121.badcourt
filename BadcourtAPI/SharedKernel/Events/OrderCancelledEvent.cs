using SharedKernel.DTOs;

namespace SharedKernel.Events;

public record OrderCancelledEvent(string OrderId, string CourtId, string UserId, DateTimePeriodDto DateTimePeriodDto);
