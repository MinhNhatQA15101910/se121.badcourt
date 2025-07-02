using SharedKernel.DTOs;

namespace CourtService.Core.Application.DTOs;

public class UpdateInactiveDto
{
    public DateTimePeriodDto DateTimePeriod { get; set; } = new DateTimePeriodDto();
    public string TimeZoneId { get; set; } = "UTC";
}
