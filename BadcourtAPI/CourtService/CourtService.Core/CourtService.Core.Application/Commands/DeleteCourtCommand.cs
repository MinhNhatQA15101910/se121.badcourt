namespace CourtService.Core.Application.Commands;

public record DeleteCourtCommand(string CourtId) : ICommand<bool>;
