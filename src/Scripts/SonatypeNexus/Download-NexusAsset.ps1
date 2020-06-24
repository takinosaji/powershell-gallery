<#PSScriptInfo
.VERSION 1.0
.GUID cee98fd5-f702-4b41-82c0-50316c220b14
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
    [string]$NexusUri,
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$false)]
    [string]$RepositoryName,
    [Parameter(Mandatory=$false)]
    [string]$AssetGroup,
    [Parameter(Mandatory=$false)]
    [string]$KeyWord,
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSec = 600
)

if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}
 
"$PSScriptRoot/../../Modules/Utilities/Utilities.psd1" | 
Import-Module -Force -Scope Global @commonParams
 
$params = @{
    "Uri"        = "$NexusUri/service/rest/v1/search/assets/download?repository=$RepositoryName&q=$KeyWord&group=$AssetGroup"
    "Method"     = "GET"
    "Headers"    = @{ Authorization = "Basic $ApiKey"; "User-Agent" = "" }
    "TimeoutSec" =  $TimeoutSec
    "OutFile" = $FilePath
}
 
"Downloading asset from: $($params.Uri)" | Write-Host
 
return { Invoke-RestMethod @params } | Retry-ScriptBlock

