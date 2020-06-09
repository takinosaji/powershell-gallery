<#PSScriptInfo
.VERSION 1.0
.GUID 1eda292c-9477-468a-9e71-cd0f75300c69
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
 This script allows you to remove KeyValuePair from existing secret in HashiCorp KeyValueStorage Engine 
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
    [string]$Key,
    [Parameter(Mandatory=$false)]
    [string]$EntryNamespace = "/",
    [Parameter(Mandatory=$false)]
    [string]$ApiVersion = "v1"
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
 
if(!$secret.$Key) { throw "Key: $Key is absend in requested version of secret" }
 
$propertyCount = @($secret | Get-Member -MemberType NoteProperty).Length
 
if($propertyCount -eq 1) {
    $secret = @{}
} else {
    $secret = $secret | Select-Object -Property * -ExcludeProperty $Key
}
            
$SecretName | 
    Write-KVSecret -VaultUrl $VaultUrl `
                   -KeyValueEnginePath "$EntryNamespace/$RelativeSecretPath" `
                   -SecretValue $secret `
                   -Token $token `
                   -UseBasicUrlParsing:$UseBasicUrlParsing