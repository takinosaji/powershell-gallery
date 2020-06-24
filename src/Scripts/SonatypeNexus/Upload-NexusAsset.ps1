<#PSScriptInfo
.VERSION 1.0
.GUID 5c41824e-b97e-4bbe-a273-9fd7d97079ce
.AUTHOR Serhii Koval
.COMPANYNAME
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
 This script allows you to compose MS SQL Connection string
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,
    [Parameter(Mandatory=$true)]
    [string]$RepositoryUri,
    [Parameter(Mandatory=$true)]
    [string]$AssetName,
    [Parameter(Mandatory=$true)]
    [string]$AssetVersion,    
    [Parameter(Mandatory=$true)]
    [string]$AssetGroup = $AssetVersion,
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSec = 600,
    [switch]$UseBasicParsing
)

if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}
 
"$PSScriptRoot/../../Modules/Utilities/Utilities.psd1" | 
Import-Module -Force -Scope Global @commonParams
 
$params = @{
    "Uri"     = "$RepositoryUri/$AssetGroup/$AssetName-$AssetVersion.zip"
    "Method"  = "PUT"
    "Headers" = @{ Authorization = "Basic $ApiKey"; "User-Agent" = "" }
    "InFile"  = $FilePath
    "TimeoutSec" =  $TimeoutSec
    "UseBasicParsing" = $UseBasicParsing
}
 
"Uploading asset to: $($params.Uri)" | Write-Host
 
return { Invoke-WebRequest @params } | Retry-ScriptBlock

