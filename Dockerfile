FROM mcr.microsoft.com/dotnet/core/sdk:2.2.105-alpine3.8 AS build
WORKDIR /app

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT false
RUN apk add --no-cache icu-libs

RUN apk add nodejs-npm

WORKDIR /app

# Restore npm packages as cacheable layer
COPY Rnwood.Smtp4dev/npm-shrinkwrap.json ./Rnwood.Smtp4dev/
COPY Rnwood.Smtp4dev/package.json ./Rnwood.Smtp4dev/

WORKDIR /app/Rnwood.Smtp4dev
RUN npm install
WORKDIR /app

# Restore nuget packages as cacheable layer
COPY *.sln .
COPY Rnwood.Smtp4dev/*.csproj ./Rnwood.Smtp4dev/
RUN dotnet restore -r linux-x64 Rnwood.Smtp4dev

# copy everything else and build app
WORKDIR /app
ARG version
ENV VERSION $version
COPY . .
WORKDIR /app/Rnwood.Smtp4dev
RUN dotnet publish -c Release -o out -f netcoreapp2.2 -r linux-x64 -p:Version=$VERSION

FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2 AS runtime
WORKDIR /app
EXPOSE 80
EXPOSE 25
COPY --from=build /app/Rnwood.Smtp4dev/out ./
ENTRYPOINT ["./Rnwood.Smtp4dev"]