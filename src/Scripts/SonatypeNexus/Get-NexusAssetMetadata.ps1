<#PSScriptInfo
.VERSION 1.0
.GUID 2fd7a448-ae73-4b48-bef9-0ac7c221c8dd
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
    [Parameter(Mandatory=$false)]
    [string]$RepositoryName,
    [Parameter(Mandatory=$false)]
    [string]$AssetGroup,
    [Parameter(Mandatory=$false)]
    [string]$KeyWord,
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSec = 300
)
 
if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$params = @{
    "Uri"     = "$NexusUri/service/rest/v1/search/assets?repository=$RepositoryName&q=$KeyWord&group=$AssetGroup"
    "Method"  = "GET"
    "Headers" = @{ Authorization = "Basic $ApiKey"; "User-Agent" = "" }
    "TimeoutSec" =  $TimeoutSec
}
 
"Searching assets by query: $($params.Uri)" | Write-Host
 
$assets = Invoke-RestMethod @params
 
return $assets.items