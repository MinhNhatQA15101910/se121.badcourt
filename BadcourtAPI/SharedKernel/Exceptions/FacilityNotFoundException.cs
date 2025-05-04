namespace SharedKernel.Exceptions;

public class FacilityNotFoundException(string facilityId)
    : NotFoundException($"The facility with the identifier {facilityId} was not found.")
{
}
