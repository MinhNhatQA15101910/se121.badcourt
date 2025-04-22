using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using FacilityService.Core.Application.Interfaces;
using FacilityService.Infrastructure.Configuration;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;

namespace FacilityService.Infrastructure.Services;

public class FileService : IFileService
{
    private readonly Cloudinary _cloudinary;
    private readonly string _folderRoot;

    public FileService(IOptions<CloudinarySettings> config)
    {
        var acc = new Account(
            config.Value.CloudName,
            config.Value.ApiKey,
            config.Value.ApiSecret
        );

        _cloudinary = new Cloudinary(acc);

        _folderRoot = config.Value.FolderRoot;
    }

    public async Task<DeletionResult> DeleteFileAsync(string publicId, ResourceType resourceType)
    {
        var deletionParams = new DeletionParams(publicId)
        {
            ResourceType = resourceType
        };

        var deletionResult = await _cloudinary.DestroyAsync(deletionParams);
        return deletionResult;
    }

    public async Task<ImageUploadResult> UploadPhotoAsync(string folderPath, IFormFile file)
    {
        var uploadResult = new ImageUploadResult();

        if (file.Length > 0)
        {
            using var stream = file.OpenReadStream();
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Folder = _folderRoot + "/" + folderPath
            };

            uploadResult = await _cloudinary.UploadAsync(uploadParams);
        }

        return uploadResult;
    }
}
