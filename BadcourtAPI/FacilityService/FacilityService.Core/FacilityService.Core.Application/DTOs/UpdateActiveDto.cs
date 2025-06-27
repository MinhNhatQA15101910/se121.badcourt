using SharedKernel.DTOs;

namespace FacilityService.Core.Application.DTOs;

public class UpdateActiveDto
{
    public ActiveDto Active { get; set; } = new ActiveDto();
    public string TimeZoneId { get; set; } = "UTC";
}
