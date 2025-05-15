using SharedKernel.DTOs;

namespace SharedKernel.Events;

public record OrderCreatedEvent(string CourtId, DateTimePeriodDto DateTimePeriodDto);
