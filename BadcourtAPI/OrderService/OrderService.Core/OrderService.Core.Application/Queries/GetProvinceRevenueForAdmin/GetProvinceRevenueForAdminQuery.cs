using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetProvinceRevenueForAdmin;

public record GetProvinceRevenueForAdminQuery(
    AdminDashboardProvinceRevenueParams ProvinceRevenueParams
) : IQuery<List<ProvinceRevenueDto>>;
