<#PSScriptInfo
.VERSION 1.0
.GUID db309ce2-bbe5-440e-a93c-5a86f4c7d5c2
.AUTHOR Kostiantyn Chomakov
.COMPANYNAME
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
 This script allows you to compose MS SQL Connection string
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Server,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Database,
    [Parameter(Mandatory=$true, ParameterSetName="UserPassword", Position=3)]
    [string]$User,
    [Parameter(Mandatory=$true, ParameterSetName="UserPassword", Position=4)]
    [string]$Password,
    [Parameter(Mandatory=$false, HelpMessage="Hashtables should consist of keys: [Key, Value].")]
    [hashtable[]]$AdditionalParams = @(),
    [Parameter(ParameterSetName="IntegratedSecurity")]
    [switch]$IntegratedSecurity
)
 
if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
$commonParams = @{
ErrorAction = $ErrorActionPreference;
Verbose = $VerbosePreference -ne 'SilentlyContinue'
}
 
$builder = New-Object -TypeName System.Data.SqlClient.SqlConnectionStringBuilder @commonParams
 
$builder['Data Source'] = $Server
$builder['Initial Catalog'] = $Database
 
if (!$IntegratedSecurity) {
$builder.Password = $Password
$builder['User ID'] = $User
} else {
$builder['Integrated Security'] = $true
}
 
$AdditionalParams | ForEach-Object { $builder[$_.Key] = $_.Value } 
 
$builder.ConnectionString


 

