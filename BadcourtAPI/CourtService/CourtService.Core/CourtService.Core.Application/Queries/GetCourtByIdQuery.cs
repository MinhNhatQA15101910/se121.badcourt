using SharedKernel.DTOs;

namespace CourtService.Core.Application.Queries;

public record GetCourtByIdQuery(string Id) : IQuery<CourtDto>;
