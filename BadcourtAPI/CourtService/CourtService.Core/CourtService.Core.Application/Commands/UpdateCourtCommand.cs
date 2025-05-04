using CourtService.Core.Application.DTOs;

namespace CourtService.Core.Application.Commands;

public record UpdateCourtCommand(string CourtId, UpdateCourtDto UpdateCourtDto) : ICommand<bool>;
