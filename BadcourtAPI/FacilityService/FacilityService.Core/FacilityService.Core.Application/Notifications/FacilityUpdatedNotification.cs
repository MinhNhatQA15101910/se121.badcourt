using FacilityService.Core.Domain.Entities;
using MediatR;

namespace FacilityService.Core.Application.Notifications;

public record FacilityUpdatedNotification(Facility UpdatedFacility) : INotification;
