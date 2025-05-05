using CourtService.Core.Application.DTOs;
using SharedKernel.DTOs;

namespace CourtService.Core.Application.Commands;

public record AddCourtCommand(AddCourtDto AddCourtDto) : ICommand<CourtDto>;
