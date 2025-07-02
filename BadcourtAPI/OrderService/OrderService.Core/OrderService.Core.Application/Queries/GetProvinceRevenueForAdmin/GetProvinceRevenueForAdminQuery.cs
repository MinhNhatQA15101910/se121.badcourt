using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetProvinceRevenueForAdmin;

public record GetProvinceRevenueForAdminQuery(
    AdminDashboardProvinceRevenueParams ProvinceRevenueParams
) : IQuery<PagedList<ProvinceRevenueDto>>;
