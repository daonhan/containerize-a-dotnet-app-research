#####################################################################################
# Requirements for this demo
# 1. Install docker          - https://docs.docker.com/desktop/#download-and-install 
# 2. Install dotnet core sdk - https://dotnet.microsoft.com/download/dotnet-core
#####################################################################################


#####################################################################################
# Container Fundamentals
# - Binaries, libraries, and other components
# - Container image - binary application package
# - Container - running container image
# - One app inside the container
# - Generally very small and very portable
# - Container Registries - enables exchanging of container images
#####################################################################################

# The COPY command tells Docker to copy the specified folder on your computer to a folder in the container. 
# In this example, the publish folder is copied to a folder named app in the container.

# The WORKDIR command changes the current directory inside of the container to app.

# The next command, ENTRYPOINT, tells Docker to configure the container to run as an executable. 
# When the container starts, the ENTRYPOINT command runs. When this command ends, the container will automatically stop.

# 1. Create .Net app
dotnet new console -o MyApp2 -n MyDotNet.Docker

# 2. run test
dotnet run

# 3. Publish .NET app
dotnet publish -c Release -o out
# dir .\bin\Release\net6.0\publish\

# 4. Create the Dockerfile
FROM mcr.microsft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy everything
COPY . ./
# Restore as district layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out
# Build runtime image
FROM mcr.microsft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "DotNet.Docker.dll"]

# 5. build the Docker image
# Dockerfile ref: https://docs.docker.com/engine/reference/builder/
docker build . -t dotnet-docker-image:0.0.1

# 6. Create a container
# Now that you have an image that contains your app, you can create a container. 
# You can create a container in two ways. First, create a new container that is stopped.
docker create --name dotnet-docker-container dotnet-docker-image:v0.0.2

# The docker create command from above will create a container based on the dotnet-docker-image image.

# 7. Manage the container
# 7.1 start container: using the docker start command
docker start dotnet-docker-container

# 7.2 Use the docker attach commands to peek at the output stream
docker attach --sig-proxy=false dotnet-docker-container

# 8. Delete a container: using the docker stop command
docker stop dotnet-docker-container
docker rm dotnet-docker-container

# 9. Single run
docker run -it --rm dotnet-docker-image:0.0.1

docker run -d -p 8180:80 --name myapp nhan-webapi:v0.0.0
