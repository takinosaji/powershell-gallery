<#PSScriptInfo
.VERSION 1.0
.GUID 728c25a7-3b5a-4a82-9621-6f46a3810155
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
 This script allows you to extend existing secret in HashiCorp KeyValueStorage Engine with new KeyValuePair
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
    [Parameter(Mandatory=$true)]
    [string]$RelativeSecretPath,
    [Parameter(Mandatory=$true)]
    [string]$SecretName,
    [Parameter(Mandatory=$true)]
    [string]$Key,
    [Parameter(Mandatory=$true)]
    $Value,
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
 
$secret = $SecretName | 
            Read-KVSecret -VaultUrl $VaultUrl `
                        -KeyValueEnginePath "$EntryNamespace/$RelativeSecretPath" `
                        -Token $token `
                        -UseBasicUrlParsing:$UseBasicUrlParsing | 
            Select-Object -ExpandProperty data
$secret | Add-Member -MemberType NoteProperty -Name $Key -Value $Value
    
$SecretName | 
    Write-KVSecret -VaultUrl $VaultUrl `
                   -KeyValueEnginePath "$EntryNamespace/$RelativeSecretPath" `
                   -SecretValue $secret `
                   -Token $token `
                   -UseBasicUrlParsing:$UseBasicUrlParsing
