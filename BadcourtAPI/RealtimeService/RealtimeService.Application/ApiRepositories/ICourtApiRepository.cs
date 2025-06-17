using SharedKernel.DTOs;

namespace RealtimeService.Application.ApiRepositories;

public interface ICourtApiRepository
{
    Task<CourtDto?> GetCourtByIdAsync(string courtId);
}
