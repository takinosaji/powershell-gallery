Import-Module Pester -Force
$PSCommandPath
Invoke-Pester (Get-ChildItem $PSScriptRoot -Recurse `
                                           -Filter "*Tests.ps1" `
                                           -Exclude (Split-Path $PSCommandPath -Leaf))