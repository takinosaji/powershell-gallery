<#PSScriptInfo
.VERSION 1.0
.GUID c255c5e3-626e-4ffc-9caa-5be41caaed49
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
 This script allows you to delete artifact from Nexus
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,
    [Parameter(Mandatory=$true)]
    [string]$NexusUri,
    [Parameter(Mandatory=$true)]
    [string]$AssetId,
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSec = 300
)
 
if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$params = @{
    "Uri"     = "$NexusUri/service/rest/v1/assets/$AssetId"
    "Method"  = "DELETE"
    "Headers" = @{ Authorization = "Basic $ApiKey"; "User-Agent" = "" }
    "TimeoutSec" =  $TimeoutSec
}
 
"Deleting asset at: $($params.Uri)" | Write-Host
 
return Invoke-RestMethod @params