# State 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and all source files
COPY . .

# Restore dependencies
WORKDIR /src/AdminService/AdminService.Presentation
RUN dotnet restore

# Publish project
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "AdminService.Presentation.dll"]
