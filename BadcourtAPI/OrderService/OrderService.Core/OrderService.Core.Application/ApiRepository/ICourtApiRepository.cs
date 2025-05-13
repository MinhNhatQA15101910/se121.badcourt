using SharedKernel.DTOs;

namespace OrderService.Core.Application.ApiRepository;

public interface ICourtApiRepository
{
    Task<CourtDto?> GetCourtByIdAsync(string courtId);
}
