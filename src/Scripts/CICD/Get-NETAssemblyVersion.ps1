<#PSScriptInfo
.VERSION 1.0
.GUID 7df5ccdd-866f-42f3-b4c0-ba71ed1705e0
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
 This script allows you to get .NET assembly from non-standard pacakge version produced by the build
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$PackageVersion   
)

$matchFound = $PackageVersion -match "\d+\.\d+\.\d+\.\d+"
if (-not $matchFound) {
    throw "Unable to parse .NET version from given version: $PackageVersion"
}

$Matches[0]