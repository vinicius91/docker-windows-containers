
param (
    [string]$RequiredVersion = '17.06.2-ee-10',
    [string]$ZipNameVersion = 'docker-17-06-2-ee-10.zip',
    [string]$username = 'vinicius.rodrigues'
  )
  $downloadURL = "https://dockermsft.blob.core.windows.net/dockercontainer/$($ZipNameVersion)"
  $copyPath = "C:\Users\$($username)\AppData\Local\Temp\DockerMsftProvider\"
  # Install the Docker Module Provider
  Install-Module -Name DockerMsftProvider -Repository PSGallery
  # Downloads the Version
  Start-BitsTransfer -Source $downloadURL -Destination c:\cd\docker.zip
  # Copy the version to the instalation folder
  Copy-Item .\docker.zip $copyPath
  # Renaming to the desired version name
  Set-Location $copyPath
  Copy-Item .\docker.zip $ZipNameVersion
  # Installing the desired version  
  Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose -RequiredVersion $RequiredVersion
  # Restart the VM
  Restart-Computer -Force

  # The Service will not start normaly after this instalation
  # You need to edit the Registry First
  # run regedit
  # Alter the following registry
  # (HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Docker\ImagePath)
  # To: C:\Program Files\Docker\dockerd.exe --run-service -H npipe:// -b "none"
  # After this Start the Docker Service