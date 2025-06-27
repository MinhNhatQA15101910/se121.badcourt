using CourtService.Core.Application.DTOs;

namespace CourtService.Core.Application.Commands;

public record UpdateInactiveCommand(
    string CourtId,
    UpdateInactiveDto UpdateInactiveDto
) : ICommand<bool>;
