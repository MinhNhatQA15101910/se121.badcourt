# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy everything into the container
COPY . .

# Restore dependencies
WORKDIR /src/APIGateway
RUN dotnet restore

# Build and publish the project
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Set environment variable so the app listens on port 5000
ENV ASPNETCORE_URLS=http://+:5000

# Copy the published output from the build stage
COPY --from=build /app/publish .

# Expose port 5000 (optional but useful for documentation)
EXPOSE 5000

ENTRYPOINT ["dotnet", "APIGateway.dll"]
