Describe "Get-BuildName" {
    BeforeAll {
        $scriptFile = "$PSScriptRoot\..\..\..\src\scripts\CICD\Get-BuildName.ps1"
    }

    It "Produces correct name" {
        $buildName = &$scriptFile -CurrentBranchName "pr/kc/pbi-name!2%;_with=unexpected symbols" `
                                  -PackageVersion "2020.4.6.17-dev177345"

        $buildName | Should -Be "2020.4.6.17-dev177345-pr_kc_pbi_name_2_with_unexpected_symbols"
    }
}