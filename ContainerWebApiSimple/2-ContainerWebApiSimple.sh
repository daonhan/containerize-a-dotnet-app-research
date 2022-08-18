# 1. create webapi project
# dotnet new webapi -n ContainerWebApiSimple -o ContainerWebApiSimple
dotnet new webapi -n UA.WebApi -o UA.WebApi

# 2. create Dockerfile or 
# 	Right-click the project in the IDE and select Add → Docker Support
#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
WORKDIR "/src/."
RUN dotnet build "ContainerWebApiSimple.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ContainerWebApiSimple.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ContainerWebApiSimple.dll"]

# 3. build the Docker image
docker build . -t container-webapi-simple:0.0.1

# 4. list all all container-webapi-simple docker images
docker image ls --filter "reference=*container-webapi-simple*" 

# 5. Test if the container starts successfully
docker run --rm container-webapi-simple:0.0.1

# 6. scan image for vulnerabilities
docker scan container-webapi-simple:0.0.1