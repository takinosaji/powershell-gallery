<#PSScriptInfo
.VERSION 1.0
.GUID f17060ec-7fa3-4891-8bb4-07b708b235da
.AUTHOR Kostiantyn Chomakov
.COMPANYNAME EXDEV LAB
.COPYRIGHT
.TAGS
.LICENSEURI
.PROJECTURI
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
#>
<#
.DESCRIPTION
 This script allows you to run ngrok inside container in your local docker host.
#>
[CmdletBinding()]
param(
    [string]$ContainerName = "ngrok",
    [string]$NgrokPort = 4040,
    [string]$NgrokNetworkName = "myngroknet",
    [string]$TunnelPort = 8080
)
 
if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}

$ngrokNetworkExists = docker network ls | ? { $_ -match $NgrokNetworkName } 
if (-not $ngrokNetworkExists) {
    docker network create $NgrokNetworkName
}

$ngrokContainerExists = docker ps | ? { $_ -match $ContainerName }
if ($ngrokContainerExists) {
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
}

$containerId = & docker @(
    'run', 
    '-d',  
    '-p', "$($NgrokPort):$($NgrokPort)", 
     '--net', "$NgrokNetworkName", 
     '--name', $ContainerName, 
     'wernight/ngrok', 
     $ContainerName, 
     'http', "localhost:$TunnelPort")

"ngrok is running in $containerId" | Out-Host

$ngrokConfig = Invoke-WebRequest "http://localhost:$NgrokPort/api/tunnels" -UseBasicParsing @commonParams |
    Select-Object -ExpandProperty Content |
    ConvertFrom-Json
"ngrok tunnels: $($ngrokConfig.tunnels[0].public_url)" | Out-Host

"Press any key to exit" | Out-Host

Read-Host | Out-Null

docker stop $containerId | Out-Null
docker rm $containerId | Out-Null
docker network rm $NgrokNetworkName | Out-Null