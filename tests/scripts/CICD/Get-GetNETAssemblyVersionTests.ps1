Describe "Get-GetNETAssemblyVersion" {
    BeforeAll {
        $currentDate = Get-Date -AsUTC
        $scriptFile = "$PSScriptRoot\..\..\..\src\scripts\CICD\Get-GetNETAssemblyVersion.ps1"
    }

    It "Produces correct .NET version out of dev package version" {
        $version = &$scriptFile -PackageVersion "2020.4.6.17-dev177345-pr_kc_pbi_name" 

        $version | Should -Be "2020.4.6.17"
    }    
}