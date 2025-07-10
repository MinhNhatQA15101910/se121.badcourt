# State 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and all source files
COPY . .

# Restore dependencies
WORKDIR /src/ManagerService/ManagerService.Presentation
RUN dotnet restore

# Publish project
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Set environment variable so the app listens on port 1000
ENV ASPNETCORE_URLS=http://+:9000

# Copy the published output from the build stage
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "ManagerService.Presentation.dll"]
