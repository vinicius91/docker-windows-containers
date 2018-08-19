# This is the docker container database setup for astro in a Windows Container environment

$base_bak_path = "C:\Backup\astro"
$sa_password = "uVAfkTULa6ijD5DNjsMh"
Set-Location $base_bak_path

docker pull microsoft/mssql-server-windows-developer:latest
docker run --name sqlastro -p 1401:1433 -d -e "ACCEPT_EULA=Y" -e "sa_password=$($sa_password)" -v C:/temp/:C:/temp/ -d microsoft/mssql-server-windows-developer:latest

mkdir C:\temp\Backup
Copy-Item astro.bak C:\temp\Backup

$sa_password = "uVAfkTULa6ijD5DNjsMh"
docker exec -it sqlastro sqlcmd -S localhost `
    -U sa -P "$($sa_password)" `
    -Q "RESTORE FILELISTONLY FROM DISK = 'C:\temp\Backup\astro.bak'"

docker exec -it sqlastro sqlcmd `
    -S localhost -U sa -P "$($sa_password)" `
    -Q "RESTORE DATABASE astro FROM DISK = 'C:\temp\Backup\astro.bak' WITH MOVE 'astro' TO 'C:\temp\astro.mdf', MOVE 'astro_log' TO 'C:\temp\astro_log.ldf'"

# Verify if database is restored
docker exec -it sqlastro sqlcmd `
    -S localhost -U sa -P "$($sa_password)" `
    -Q "SELECT Name FROM sys.Databases"

# Verify if data is restored
docker exec -it sqlastro sqlcmd `
    -S localhost -U sa -P "$($sa_password)" `
    -Q "SELECT TOP 10 Id,CreatedAt  FROM astro.dbo.Clients ORDER BY CreatedAt DESC"

# Useful commands

# # Creating a Backup
# docker exec -it sqlastro /opt/mssql-tools/bin/sqlcmd `
#     -S localhost -U sa -P "u_E#cb5mgF$Bb!g_" `
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
#     -S localhost -U sa -P "$($sa_password)" `
#     -Q "ALTER LOGIN sa WITH PASSWORD='uVAfkTULa6ijD5DNjsMh'"
