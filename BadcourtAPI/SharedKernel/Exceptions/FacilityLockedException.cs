namespace SharedKernel.Exceptions;

public class FacilityLockedException(string facilityId) 
    : ForbiddenAccessException($"Facility with ID {facilityId} is locked and cannot be accessed.")
{
}
