using SharedKernel.DTOs;

namespace SharedKernel.Events;

public record CourtInactiveUpdatedEvent(string CourtId, DateTimePeriodDto DateTimePeriodDto);
