using AutoMapper;
using CloudinaryDotNet.Actions;
using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.Extensions;
using FacilityService.Core.Application.Interfaces;
using FacilityService.Core.Domain.Entities;
using FacilityService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using MongoDB.Bson;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class UpdateFacilityHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityRepository facilityRepository,
    IFileService fileService,
    IMapper mapper
) : ICommandHandler<UpdateFacilityCommand, bool>
{
    public async Task<bool> Handle(UpdateFacilityCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        var httpUser = (httpContextAccessor.HttpContext?.User)
            ?? throw new UnauthorizedAccessException();

        var roles = httpUser.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpUser.GetUserId();
            if (facility.UserId != userId)
            {
                throw new UnauthorizedAccessException("You do not have permission to update this facility.");
            }
        }

        // Patch scalar fields
        mapper.Map(request.UpdateFacilityDto, facility);

        // Replace facility photos
        if (request.UpdateFacilityDto.FacilityImages.Count != 0)
        {
            await DeleteImagesAsync(facility.Photos.Select(p => new Photo
            {
                PublicId = p.PublicId,
                Url = p.Url
            }));
            facility.Photos = [.. (await UploadMultiplePhotosAsync(
                $"facilities/{facility.Id}",
                request.UpdateFacilityDto.FacilityImages,
                withMain: true
            )).Select(p => new FacilityPhoto
            {
                Id = ObjectId.GenerateNewId().ToString(),
                Url = p.Url,
                PublicId = p.PublicId,
                IsMain = p.IsMain
            })];
        }

        // Ensure ManagerInfo is not null
        facility.ManagerInfo ??= new ManagerInfo();

        // Replace single images
        if (request.UpdateFacilityDto.CitizenImageFront != null)
        {
            facility.ManagerInfo.CitizenImageFront = await DeleteAndUploadSingleImageAsync(
                facility.ManagerInfo.CitizenImageFront,
                request.UpdateFacilityDto.CitizenImageFront,
                $"facilities/{facility.Id}/citizen_images"
            );
        }

        if (request.UpdateFacilityDto.CitizenImageBack != null)
        {
            facility.ManagerInfo.CitizenImageBack = await DeleteAndUploadSingleImageAsync(
                facility.ManagerInfo.CitizenImageBack,
                request.UpdateFacilityDto.CitizenImageBack,
                $"facilities/{facility.Id}/citizen_images"
            );
        }

        if (request.UpdateFacilityDto.BankCardFront != null)
        {
            facility.ManagerInfo.BankCardFront = await DeleteAndUploadSingleImageAsync(
                facility.ManagerInfo.BankCardFront,
                request.UpdateFacilityDto.BankCardFront,
                $"facilities/{facility.Id}/bank_cards"
            );
        }

        if (request.UpdateFacilityDto.BankCardBack != null)
        {
            facility.ManagerInfo.BankCardBack = await DeleteAndUploadSingleImageAsync(
                facility.ManagerInfo.BankCardBack,
                request.UpdateFacilityDto.BankCardBack,
                $"facilities/{facility.Id}/bank_cards"
            );
        }

        // Replace business license images
        if (request.UpdateFacilityDto.BusinessLicenseImages.Count != 0)
        {
            await DeleteImagesAsync(facility.ManagerInfo.BusinessLicenseImages);
            facility.ManagerInfo.BusinessLicenseImages = await UploadMultiplePhotosAsync(
                $"facilities/{facility.Id}/business_licenses",
                request.UpdateFacilityDto.BusinessLicenseImages,
                withMain: true
            );
        }

        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        return true;
    }

    private async Task<Photo> UploadSinglePhotoAsync(string folder, IFormFile file)
    {
        var result = await fileService.UploadPhotoAsync(folder, file);
        if (result.Error != null)
            throw new BadRequestException(result.Error.Message);

        return new Photo
        {
            Url = result.SecureUrl.ToString(),
            PublicId = result.PublicId,
            IsMain = false
        };
    }

    private async Task<List<Photo>> UploadMultiplePhotosAsync(string folder, IEnumerable<IFormFile> files, bool withMain = false)
    {
        var photos = new List<Photo>();
        bool isMain = withMain;
        foreach (var file in files)
        {
            var result = await fileService.UploadPhotoAsync(folder, file);
            if (result.Error != null)
                throw new BadRequestException(result.Error.Message);

            photos.Add(new Photo
            {
                Url = result.SecureUrl.ToString(),
                PublicId = result.PublicId,
                IsMain = isMain
            });

            isMain = false;
        }

        return photos;
    }

    private async Task<Photo> DeleteAndUploadSingleImageAsync(Photo? oldPhoto, IFormFile newFile, string folder)
    {
        if (oldPhoto?.PublicId != null)
        {
            var deleteResult = await fileService.DeleteFileAsync(oldPhoto.PublicId, ResourceType.Image);
            if (deleteResult.Error != null)
                throw new BadRequestException(deleteResult.Error.Message);
        }

        return await UploadSinglePhotoAsync(folder, newFile);
    }

    private async Task DeleteImagesAsync(IEnumerable<Photo> photos)
    {
        foreach (var photo in photos)
        {
            if (photo.PublicId != null)
            {
                var result = await fileService.DeleteFileAsync(photo.PublicId, ResourceType.Image);
                if (result.Error != null)
                {
                    throw new BadRequestException(result.Error.Message);
                }
            }
        }
    }
}
