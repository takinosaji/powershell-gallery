<#PSScriptInfo
.VERSION 1.0
.GUID 654c563a-0292-4e85-81ce-5a6a1daf4fdd
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
 This script allows you to run pester tests
#>

if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}

Import-Module Pester -Force @commonParams

Invoke-Pester (Get-ChildItem $PSScriptRoot -Recurse `
                                           -Filter "*Tests.ps1" `
                                           -Exclude (Split-Path $PSCommandPath -Leaf))