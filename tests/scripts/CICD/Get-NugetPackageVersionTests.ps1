Describe "Get-GetNugetPackageVersion" {
    BeforeAll {
        $currentDate = Get-Date -AsUTC
        $scriptFile = "$PSScriptRoot\..\..\..\src\scripts\CICD\Get-GetNugetPackageVersion.ps1"
    }

    It "Produces correct dev package version with PBI nubmer in branch name" {
        $version = &$scriptFile -MainlineBranchPattern "release" `
                                -CurrentBranchName "pr/kc/pbi-number-follows-456789-and-more-numbers-1234" `
                                -BuildCounter 1

        $version | Should -Be "$($currentDate.Year).$($currentDate.Month).$($currentDate.Day).1-dev456789"
    }    

    It "Produces correct dev package version without PBI nubmer in branch name" {
        $version = &$scriptFile -MainlineBranchPattern "release" `
                                -CurrentBranchName "pr/kc/some-dummy-name" `
                                -BuildCounter 1

        $version | Should -Be "$($currentDate.Year).$($currentDate.Month).$($currentDate.Day).1-dev000000"
    }  
    
    It "Produces correct release package version" {
        $version = &$scriptFile -MainlineBranchPattern "release" `
                                -CurrentBranchName "release" `
                                -BuildCounter 1

        $version | Should -Be "$($currentDate.Year).$($currentDate.Month).$($currentDate.Day).1"
    }
}