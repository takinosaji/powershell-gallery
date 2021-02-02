<#PSScriptInfo
.VERSION 1.0
.GUID 1685cc39-ea7d-4559-bb55-4058c9fe6c31
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
 This script allows you to assemble name for your build from package version and branch name
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$PackageVersion,    
    [Parameter(Mandatory=$true)]
    [string]$CurrentBranchName
)

"$PackageVersion-$($CurrentBranchName -replace "[^a-zA-Z\d_]", "_")" |
    % { $_ -replace "refs_heads_", "" } |
    % { $_ -replace "_{2,}", "_" }
