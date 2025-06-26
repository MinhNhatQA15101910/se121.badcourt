using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using RealtimeService.Application.Interfaces;
using RealtimeService.Infrastructure.ExternalServices.Configurations;

namespace RealtimeService.Infrastructure.ExternalServices.Services;

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

    public async Task<ImageUploadResult> UploadPhotoAsync(string folderPath, string base64Image)
    {
        var uploadResult = new ImageUploadResult();

        if (string.IsNullOrWhiteSpace(base64Image))
            return uploadResult;

        var (fileName, stream) = ConvertBase64ToStream(base64Image, "photo");

        var uploadParams = new ImageUploadParams
        {
            File = new FileDescription(fileName, stream),
            Folder = _folderRoot + "/" + folderPath
        };

        uploadResult = await _cloudinary.UploadAsync(uploadParams);
        return uploadResult;
    }

    public async Task<VideoUploadResult> UploadVideoAsync(string folderPath, IFormFile file)
    {
        var uploadResult = new VideoUploadResult();

        if (file.Length > 0)
        {
            using var stream = file.OpenReadStream();
            var uploadParams = new VideoUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Folder = _folderRoot + "/" + folderPath
            };

            uploadResult = await _cloudinary.UploadAsync(uploadParams);
        }

        return uploadResult;
    }

    public async Task<VideoUploadResult> UploadVideoAsync(string folderPath, string base64Video)
    {
        var uploadResult = new VideoUploadResult();

        if (string.IsNullOrWhiteSpace(base64Video))
            return uploadResult;

        var (fileName, stream) = ConvertBase64ToStream(base64Video, "video");

        var uploadParams = new VideoUploadParams
        {
            File = new FileDescription(fileName, stream),
            Folder = _folderRoot + "/" + folderPath
        };

        uploadResult = await _cloudinary.UploadAsync(uploadParams);
        return uploadResult;
    }

    private static (string fileName, Stream stream) ConvertBase64ToStream(string base64String, string prefix)
    {
        var dataParts = base64String.Split(',');

        // Extract MIME type for extension
        var mimeType = dataParts[0].Split(':')[1].Split(';')[0]; // e.g. image/png
        var extension = mimeType.Split('/')[1]; // e.g. png

        var fileName = $"{prefix}_{Guid.NewGuid()}.{extension}";
        var base64Data = dataParts.Length > 1 ? dataParts[1] : dataParts[0];
        var fileBytes = Convert.FromBase64String(base64Data);

        var stream = new MemoryStream(fileBytes);
        return (fileName, stream);
    }
}
