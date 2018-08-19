# This is the docker container database setup for astro in a Linux Container environment

$base_bak_path = "C:\Backup\astro"
$sa_password = "uVAfkTULa6ijD5DNjsMh"

Set-Location $base_bak_path

docker pull microsoft/mssql-server-linux:latest
docker run --name sqlastro -p 1401:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$($sa_password)" -e "MSSSQL_PID=Developer" -v astrodata:/var/opt/mssql -d microsoft/mssql-server-linux:latest


docker exec -it sqlastro mkdir /var/opt/mssql/backup
docker cp astro.bak sqlastro:/var/opt/mssql/backup

docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd -S localhost `
    -U SA -P "$($sa_password)" `
    -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/astro.bak'"

docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P "$($sa_password)" `
    -Q "RESTORE DATABASE astro FROM DISK = '/var/opt/mssql/backup/astro.bak' WITH MOVE 'astro' TO '/var/opt/mssql/data/astro.mdf', MOVE 'astro_log' TO '/var/opt/mssql/data/astro_log.ldf'"

# Verify if database is restored
docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P "$($sa_password)" `
    -Q "SELECT Name FROM sys.Databases"

# Verify if data is restored
docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P "$($sa_password)" `
    -Q "SELECT TOP 10 Id,CreatedAt  FROM astro.dbo.Clients ORDER BY CreatedAt DESC"

# Useful commands

# # Creating a Backup
# docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd `
#     -S localhost -U SA -P "u_E#cb5mgF$Bb!g_" `
#     -Q "BACKUP DATABASE [astro] TO DISK = N'/var/opt/mssql/backup/astro_2.bak' WITH NOFORMAT, NOINIT, NAME = 'astro', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

# # Copy backup to local machine
# $backup_path = "C:\Dev\Database\Backup"
# Set-Location $backup_path
# docker cp sqlastro:/var/opt/mssql/backup/astro_2.bak astro_backup.bak

# # Removing the container and volumes
# docker container rm -f sqlastro
# docker volume rm astrodata

# # Alter password
# docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd `
#     -S localhost -U SA -P "$($sa_password)" `
#     -Q "ALTER LOGIN SA WITH PASSWORD='uVAfkTULa6ijD5DNjsMh'"
