using SharedKernel.DTOs;

namespace CourtService.Core.Application.Commands;

public record UpdateInactiveCommand(string CourtId, DateTimePeriodDto DateTimePeriodDto) : ICommand<bool>;
