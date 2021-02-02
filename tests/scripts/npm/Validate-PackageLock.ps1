<#PSScriptInfo
.VERSION 1.0
.GUID 7a5098a1-5aa3-4fcc-a103-d8f249c041c2
.AUTHOR Kostiantyn Chomakov
.COMPANYNAME Wolters Kluwer
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
 This script allows you to validate repositories and integrity check algorythms in package-lock.json
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Please provide valid path to package-lock.json file", ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$PackageLockFilePath,
    [Parameter(Mandatory=$true)]
    [string]$ResolvedPattern,
    [Parameter(Mandatory=$true)]
    [string]$IntegrityPattern
)

#
# Functions
#

function Extract-Dependencies {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $DependencyContainer
    )

    $dependencies = @()

    $DependencyContainer.dependencies.PSObject.Properties | % {
        if ($_.value.dependencies) {
            $dependencies += Extract-Dependencies $_.value
        }
    }
    
    $dependencies += $DependencyContainer.dependencies.PSObject.Properties | select -ExpandProperty value @commonParams

    $dependencies 
}

#
# Execution
#

if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}

$packageLockContent = Get-Content $PackageLockFilePath -Raw @commonParams
$packageLockJson = ConvertFrom-Json $packageLockContent @commonParams
$dependencies = Extract-Dependencies $packageLockJson @commonParams

$integrityMismatches = @()
$resolvedMismatches = @()

$dependencies | % {
    $resolved = $_.resolved
    $integrity = $_.integrity

    if($resolved -notmatch $ResolvedPattern) {
        $resolvedMismatches += $resolved
    }

    if($integrity -notmatch $IntegrityPattern) {
        $integrityMismatches += $integrity
    }
}

if(!$integrityMismatches -and !$resolvedMismatches) {
    "Package lock has been validated and no issues have been found" | Out-Host
    "Integrity pattern: $IntegrityPattern" | Out-Host
    "Resolved pattern: $ResolvedPattern" | Out-Host
    return
}

if($integrityMismatches) {
    "Integrity mismatches against pattern [$IntegrityPattern] have been found:" | Out-Host
    $integrityMismatches | % { $_ | Out-Host }
}

if($resolvedMismatches) {
    "Resolved mismatches against pattern [$ResolvedPattern] have been found:" | Out-Host
    $resolvedMismatches | % { $_ | Out-Host }
}

throw "Validation has failed"



