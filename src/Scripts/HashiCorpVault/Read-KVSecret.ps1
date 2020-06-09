<#PSScriptInfo
.VERSION 1.0
.GUID 57c5a1fc-81e4-4ad3-b48f-67da17ac8be8
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
 This script allows you to read existing secret in HashiCorp KeyValueStorage Engine including it's metadate.
 Last published version will be returned.
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
 
$SecretName | Read-KVSecret -VaultUrl $VaultUrl `
                            -KeyValueEnginePath "$EntryNamespace/$RelativeSecretPath" `
                            -Token $token `
                            -UseBasicUrlParsing:$UseBasicUrlParsing