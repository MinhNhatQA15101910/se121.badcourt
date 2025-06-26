using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;

namespace RealtimeService.Application.Interfaces;

public interface IFileService
{
    Task<DeletionResult> DeleteFileAsync(string publicId, ResourceType resourceType);
    Task<ImageUploadResult> UploadPhotoAsync(string folderPath, IFormFile file);
    Task<ImageUploadResult> UploadPhotoAsync(string folderPath, string base64Image);
    Task<VideoUploadResult> UploadVideoAsync(string folderPath, IFormFile file);
    Task<VideoUploadResult> UploadVideoAsync(string folderPath, string base64Video);
}
