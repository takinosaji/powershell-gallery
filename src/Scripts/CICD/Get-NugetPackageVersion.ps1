<#PSScriptInfo
.VERSION 1.0
.GUID 4d322559-8946-47c0-8e1b-d5f35b8b263e
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
 This script allows you to assemble nuget package version produced by the build of source code from repository
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$MainlineBranchPattern,    
    [Parameter(Mandatory=$true)]
    [string]$CurrentBranchName,     
    [Parameter(Mandatory=$true)]
    [int]$BuildCounter
)

$currentDate = Get-Date -AsUTC

if ($CurrentBranchName -match $MainlineBranchPattern) {
    return "$($currentDate.Year).$($currentDate.Month).$($currentDate.Day).$BuildCounter"
}

$matchFound = $CurrentBranchName -match "\d+"
$pbiNumber = ($matchFound) ? $Matches[0] : "000000"
"$($currentDate.Year).$($currentDate.Month).$($currentDate.Day).$BuildCounter-dev$pbiNumber"