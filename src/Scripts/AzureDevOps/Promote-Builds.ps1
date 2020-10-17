<#PSScriptInfo
.VERSION 1.0
.GUID 3220d82b-19ce-4723-93a0-573fc37328c2
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
 This script allows you to enrich builds with specific tags in your AzureDevops
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false, HelpMessage="Please provide valid paths to psd1 files")]
    [string[]]$DataFilePaths,
    [Parameter(Mandatory=$false, HelpMessage="Please provide valid configuration object")]
    [hashtable]$DataObject,
    [Parameter(Mandatory=$true)]
    [string]$RestApiUrl,    
    [Parameter(Mandatory=$true)]
    [string]$Collection,     
    [Parameter(Mandatory=$true)]
    [string]$Project,   
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [Parameter(Mandatory=$false)]
    [string]$Proxy
)

#
# Functions
#

function Assemble-Candidates {
    [CmdletBinding()]
    param(
        [string[]]$DataFilePaths,
        [hashtable]$DataObject
    )

    if (!$DataFilePaths -and !$DataObject) {
        throw "No data file paths nor data object has been specified. Aborting processing."
    }
    if ($DataFilePaths) {
        $localizedDatas = $DataFilePaths | % { 
            Import-LocalizedData -BaseDirectory ($_ | Split-Path -Parent) `
                                    -FileName ($_ | Split-Path -Leaf) `
                                    @commonParams
        }
    
        $candidatesData = Merge-HashTables $localizedDatas  
    }

    if ($DataObject -and $DataFilePaths) {
        $candidatesData = Merge-HashTables @($candidatesData, $DataObject) -Override
    }
    elseif ($DataObject -and !$DataFilePaths) {
        $candidatesData = $DataObject
    }

    if (!$candidatesData.Candidates) {
        "Configuration data doesnt contain any candidates to promote" | Out-Default
        return
    }

    $candidatesData.Candidates
}

function Get-DefaultTagConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TagValue
    )

    @{
        Value = $TagValue
        ThrowIfExists = $false
        cancelingTags = @()
    }
}

function Process-Tag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $BuildInfo,
        [Parameter(Mandatory=$true)]
        [hashtable]$TagConfig
    )

    $tagExists = $BuildInfo.tags -contains $TagConfig.Value
    if ($TagConfig.ThrowIfExists -eq $true -and $tagExists -eq $true) {
        throw "$($BuildInfo.buildNumber) already has tag $($TagConfig.Value) set and condition ThrowIfExists is set to `$true"
    } elseif ($tagExists) {
        return "Tag `'$($TagConfig.Value)`' has not been added because has been already set"
    }

    $cancelingMet = 
        ($BuildInfo.tags | ? { $TagConfig.CancelingTags -contains $_ }).Count -gt 0
   
    if ($cancelingMet) {
        return "Tag `'$($TagConfig.Value)`' has not been added due to presence of canceling tags"
    }

    Tag-Build -RestApiUrl $RestApiUrl `
              -Collection $Collection `
              -Project $project `
              -BuildId $BuildInfo.id `
              -Tag $tagConfig.Value `
              -Token $Token `
              -Proxy $Proxy `
              @commonParams | Write-Verbose
       
    return "Tag `'$($TagConfig.Value)`' has been added to the build"
}

function Process-Candidate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Candidate
    )

    $branchPrefix = "refs%2Fheads%2F"
    
    $queryParameters = @(
        @{ Key = '$top'; Value = 1 }
        @{ Key = 'branchName'; Value = "$branchPrefix$($Candidate.BranchFilter)" }
        @{ Key = 'resultFilter'; Value = "succeeded" }
        @{ Key = 'definitions'; Value = $Candidate.DefinitionId } )
   
    $project = if ($Candidate.Project) { $Candidate.Project } else { $Project }

    $foundBuilds = Get-Builds -RestApiUrl $RestApiUrl `
                              -Collection $Collection `
                              -Project $project `
                              -QueryParameters $queryParameters `
                              -Token $Token `
                              -Proxy $Proxy `
                              @commonParams

    if ($foundBuilds.count -eq 0) {
        throw "Suitable builds for promotion has not been found for the following candidate: $($Candidate | ConvertTo-Json)"
    }

    $latestBuild = $foundBuilds.value[0]

    $Candidate.Tags | ForEach-Object {
        $tagConfig = if ($_ -is [string]) { (Get-DefaultTagConfig $_) } else { $_ }

        $result = @{
            CandidateName = $Candidate.Name
            BuildNumber = $latestBuild.buildNumber
            Actions = @()
        }

        if (!$latestBuild.keepForever) {
            Update-Build -RestApiUrl $RestApiUrl `
                         -Collection $Collection `
                         -Project $project `
                         -BuildId $latestBuild.id `
                         -UpdateParameters @{ keepForever = $true } `
                         -Token $Token `
                         -Proxy $Proxy `
                         @commonParams | Write-Verbose
            $result.Actions += "Build has retained"
        } else {
            $result.Actions += "Build is already retained"
        }
        

        $result.Actions += Process-Tag $latestBuild $tagConfig @commonParams
        $result
    }

}

function Print-Results {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable[]]$Results
    )

    $Results | % {
        $_ | Out-Host
        @([string]::Concat([System.Linq.Enumerable]::Repeat("=", 25)), ("`n")) | Out-Default
    }
}


 
#
# Execution
#

if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}

@("Utilities", "AzureDevOps") | ForEach-Object {
    "$PSScriptRoot/../../Modules/$_/$_.psd1" | 
        Import-Module -Force -Scope Global @commonParams 
}

$candidates = Assemble-Candidates -DataFilePaths $DataFilePaths `
                                  -DataObject $DataObject `
                                  @commonParams

trap {
    $results | Out-Host
    break;
}
$results = $candidates | ForEach-Object { Process-Candidate $_ @commonParams }

Print-Results $results @commonParams

           







