FROM microsoft/windowsservercore

# maintainer for image metadata
MAINTAINER viniro


SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV PGDATA c:\\sql
ENV PGPORT 5432
#not using PGUSER here due to need to run createuser downstream to create role
ENV PGDOWNLOADVER postgresql-9.5.9-1-windows-x64-binaries.zip
ENV POSTGRES_USER postgres

# download and extract binaries
RUN wget http://get.enterprisedb.com/postgresql/$env:PGDOWNLOADVER -outfile $env:PGDOWNLOADVER ; \
    expand-archive $env:PGDOWNLOADVER -force -destinationpath /postgresql ; \
    rm $env:PGDOWNLOADVER

#install VC 2013 runtime required by postgresql
#use chocolatey pkg mgr to facilitate command-line installations
RUN iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
RUN choco install vcredist2013 -y

# copy dependent script(s)
COPY . /install

WORKDIR /postgresql/pgsql/bin

# init postgresql db cluster, config and create and start service
RUN powershell /install/init-config-start-service $xenv:PGDATA $env:POSTGRES_USER

# start postgreSQL using the designated data dir
CMD powershell /install/start detached $env:PGDATA $env:POSTGRES_USER

EXPOSE 5432