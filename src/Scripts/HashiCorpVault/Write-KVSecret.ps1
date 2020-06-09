<#PSScriptInfo
.VERSION 1.0
.GUID 8ea8d853-6977-4239-87d3-8b33ec2e0627
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
 This script allows you to create or completely override existing secret in HashiCorp KeyValueStorage Engine.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$VaultUrl,
    [Parameter(Mandatory=$true, ParameterSetName="AppRole")]
    [string]$RoleId,
    [Parameter(Mandatory=$true, ParameterSetName="AppRole")]
    [string]$RoleSecretId,
    [Parameter(Mandatory=$true, ParameterSetName="GCE")]
    [string]$RoleName,
    [Parameter(Mandatory=$true, ParameterSetName="Token")]
    [string]$Token,
    [Parameter(Mandatory=$true, HelpMessage="Path to secret without EntryNamespace")]
    [string]$RelativeSecretPath,
    [Parameter(Mandatory=$true)]
    [string]$SecretName,
    [Parameter(Mandatory=$true)]
    $SecretValue,
    [Parameter(Mandatory=$false)]
    [string]$EntryNamespace = "/",
    [Parameter(Mandatory=$false)]
    [string]$ApiVersion = "v1",
    [switch]$UseBasicUrlParsing
)
 
if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$commonParams = @{
    ErrorAction = $ErrorActionPreference;
    Verbose = $VerbosePreference -ne 'SilentlyContinue'
}
 
$moduleName = "HashiCorpVault"
"$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
    Import-Module -Force -Scope Global @commonParams 
 
if ($RoleId -and $RoleSecretId) {
    $token = Login-AppRole -VaultUrl $VaultUrl `
                    -RoleId $RoleId `
                    -SecretId $RoleSecretId `
                    -EntryNamespace $EntryNamespace `
                    -UseBasicUrlParsing:$UseBasicUrlParsing
} elseif ($RoleName) {
    $token = Login-GCE -VaultUrl $VaultUrl `
                    -RoleName $RoleName `
                    -EntryNamespace $EntryNamespace `
                    -UseBasicUrlParsing:$UseBasicUrlParsing
} elseif ($Token) { $token = $Token }
  else { throw "Unable to validate parameters" }
 
$SecretName | Write-KVSecret -VaultUrl $VaultUrl `
                             -KeyValueEnginePath "$EntryNamespace/$RelativeSecretPath" `
                             -SecretValue $SecretValue `
                             -Token $token `
                             -UseBasicUrlParsing:$UseBasicUrlParsing