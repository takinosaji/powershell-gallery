<#PSScriptInfo
.VERSION 1.0
.GUID 51db5e2b-e548-4ce4-a74d-f15db15fb425
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
 This script allows you to download and run portable ngrok executable
#>
[CmdletBinding()]
param(
    [string]$TunnelPort = 8080
)
 
if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}

$ngrokExeFullPath = "$PSScriptRoot\ngrok.exe"
$ngrokArchFullPath = "$PSScriptRoot\ngrok.zip"

if (-not (Test-Path $ngrokExeFullPath)) {
    Invoke-WebRequest https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -OutFile $ngrokArchFullPath @commonParams
    Expand-Archive -Path $ngrokArchFullPath -DestinationPath $PSScriptRoot
}

&$ngrokExeFullPath http $TunnelPort
