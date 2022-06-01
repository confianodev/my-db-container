ARG DBNAME=MyDb
ARG PASSWORD=C0mposed

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src

COPY src .
RUN dotnet build ./MyDb.csproj -c Release -o /app/build

FROM mcr.microsoft.com/mssql/server:2017-latest AS final

# Install Unzip
RUN apt-get update \
    && apt-get install unzip -y

# Install SQLPackage for Linux and make it executable
RUN wget -progress=bar:force -q -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2165213 \
    && unzip -qq sqlpackage.zip -d /opt/sqlpackage \
    && chmod +x /opt/sqlpackage/sqlpackage

# Add the DACPAC to the image
COPY --from=build /app/build/MyDb.dacpac /tmp/db.dacpac

# Configure external build arguments to allow configurability.
ARG DBNAME
ARG PASSWORD

# Configure the required environmental variables
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=$PASSWORD

# Launch SQL Server, confirm startup is complete, deploy the DACPAC, then terminate SQL Server.
# See https://stackoverflow.com/a/51589787/488695
RUN ( /opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" \
    && /opt/sqlpackage/sqlpackage /a:Publish /tsn:. /tdn:$DBNAME /tu:sa /tp:$SA_PASSWORD /sf:/tmp/db.dacpac \
    && rm /tmp/db.dacpac \
    && pkill sqlservr