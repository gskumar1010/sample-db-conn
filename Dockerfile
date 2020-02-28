FROM microsoft/dotnet:2.2.102-sdk as build-env
ENV ASPNETCORE_ENVIRONMENT=Testing
RUN mkdir /app
WORKDIR /app

# copy the project and restore as distinct layers in the image
COPY *.csproj ./
RUN dotnet restore

# copy the rest and build
COPY . ./
RUN dotnet build
RUN dotnet publish -c Release -o out

# build runtime image
FROM microsoft/dotnet:2.2.1-aspnetcore-runtime as 1
RUN apt-get update &&     apt-get install -y wget &&     apt-get install -y gnupg2 &&     wget -qO- https://deb.nodesource.com/setup_6.x  | bash - &&     apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
RUN apt-get update && apt-get -y install ca-certificates

COPY --from=build-env /app/out ./
ENV ASPNETCORE_ENVIRONMENT=Testing
ENV ASPNETCORE_URLS=http://*:8080

EXPOSE 8080
ENTRYPOINT ["dotnet", "SampleDBConn.dll"]
