# PowerShell Script to install latest etcd on Windows

Write-Host "You are running a script from https://github.com/jim-junior/etcd-guide"

# Set target install path
$installDir = "C:\etcd"

# Determine architecture
$arch = $env:PROCESSOR_ARCHITECTURE
switch ($arch) {
    "AMD64" { $arch = "amd64" }
    default {
        Write-Error "Unsupported architecture: $arch"
        exit 1
    }
}

# Get the latest release tag from GitHub
$releaseInfo = Invoke-RestMethod https://api.github.com/repos/etcd-io/etcd/releases/latest
$version = $releaseInfo.tag_name
Write-Host "Latest etcd version: $version"

# Compose file name and download URL
$filename = "etcd-$version-windows-$arch.zip"
$url = "https://github.com/etcd-io/etcd/releases/download/$version/$filename"

# Download the archive
$tempZip = "$env:TEMP\$filename"
Write-Host "Downloading $url..."
Invoke-WebRequest -Uri $url -OutFile $tempZip

# Extract the zip
Write-Host "Extracting..."
Expand-Archive -Path $tempZip -DestinationPath $env:TEMP -Force
$extractedFolder = "$env:TEMP\etcd-$version-windows-$arch"

# Create install directory
if (!(Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory | Out-Null
}

# Move binaries
Copy-Item "$extractedFolder\etcd.exe" $installDir -Force
Copy-Item "$extractedFolder\etcdctl.exe" $installDir -Force

# Add to PATH
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $installDir })) {
    Write-Host "Adding $installDir to system PATH..."
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$installDir", [EnvironmentVariableTarget]::Machine)
}

# Clean up
Remove-Item $tempZip
Remove-Item $extractedFolder -Recurse -Force

Write-Host "`nSUCCESS: etcd and etcdctl installed to $installDir"
Write-Host "You may need to restart your terminal or system for PATH changes to take effect."
