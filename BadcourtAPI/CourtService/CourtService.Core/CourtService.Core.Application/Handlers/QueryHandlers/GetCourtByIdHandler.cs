using AutoMapper;
using CourtService.Core.Application.Queries;
using CourtService.Core.Domain.Enums;
using CourtService.Core.Domain.Repositories;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public class GetCourtByIdHandler(
    ICourtRepository courtRepository,
    IMapper mapper
) : IQueryHandler<GetCourtByIdQuery, CourtDto>
{
    public async Task<CourtDto> Handle(GetCourtByIdQuery request, CancellationToken cancellationToken)
    {
        var court = await courtRepository.GetCourtByIdAsync(request.Id, cancellationToken)
            ?? throw new CourtNotFoundException(request.Id);

        if (court.UserState == UserState.Locked)
        {
            throw new CourtLockedException(court.Id);
        }

        return mapper.Map<CourtDto>(court);
    }
}
