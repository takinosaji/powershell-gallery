#---------------------------------------
#----PRIVATE----------------------------
#---------------------------------------
 
 

#---------------------------------------
#----PUBLIC-----------------------------
#---------------------------------------
function Login-AppRole {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultUrl,
        [Parameter(Mandatory=$true)]
        [string]$RoleId,
        [Parameter(Mandatory=$true)]
        [string]$SecretId,
        [Parameter(Mandatory=$false)]
        [string]$EntryNamespace = "/",
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "v1",
        [switch]$UseBasicUrlParsing
    )
 
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
   
        [Net.ServicePointManager]::SecurityProtocol = 
            ([Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12)
    }
 
    process {
        $completeUrl = "$VaultUrl/$ApiVersion/$EntryNamespace/auth/approle/login"
        $headers = @{ "Content-Type" = "application/json" }
        $body = @{ role_id = $RoleId; secret_id = $SecretId } | ConvertTo-Json
 
        $response = Invoke-WebRequest $completeUrl -Method POST -Headers $headers -Body $body -UseBasicParsing:$UseBasicUrlParsing @params
        $response.Content | 
            ConvertFrom-Json | 
            Select-Object -ExpandProperty auth | 
            Select-Object -ExpandProperty client_token
    }
 
    end {}
}


 
function Login-GCE {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultUrl,
        [Parameter(Mandatory=$true)]
        [string]$RoleName,
        [Parameter(Mandatory=$false)]
        [string]$EntryNamespace = "/",
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "v1",
        [switch]$UseBasicUrlParsing
    )
 
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
   
        [Net.ServicePointManager]::SecurityProtocol = 
            ([Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12)
    }
 
    process {
        $urlVaultEncode = "http%3A%2F%2Fvault%2F"
        
        $token = Invoke-WebRequest "http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=$urlVaultEncode$RoleName&format=full" `
                     -Headers @{ "Metadata-Flavor" = "Google"} `
                     -UseBasicParsing:$UseBasicUrlParsing | 
                select Content
 
        $completeUrl = "$VaultUrl/$ApiVersion/$EntryNamespace/auth/gcp/login"
        $headers = @{ "Content-Type" = "application/json" }
        $body = @{ role = $RoleName; jwt = $token.Content } | 
            ConvertTo-Json
 
        $response = Invoke-WebRequest $completeUrl -Method POST -Headers $headers -Body $body -UseBasicParsing:$UseBasicUrlParsing @params
        $response.Content | 
            ConvertFrom-Json | 
            Select-Object -ExpandProperty auth | 
            Select-Object -ExpandProperty client_token
    }
 
    end {}
}



function Read-KVSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultUrl,
        [Parameter(Mandatory=$true)]
        [string]$Token,
        [Parameter(Mandatory=$true)]
        [string]$KeyValueEnginePath,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
        [string]$SecretName,
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "v1",
        [switch]$UseBasicUrlParsing
    )
 
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
 
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
 
        [Net.ServicePointManager]::SecurityProtocol = 
            ([Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12)
    }
 
    process {
        $completeUrl = "$VaultUrl/$ApiVersion/$KeyValueEnginePath/data/$SecretName"
        $headers = @{ "X-Vault-Token" = $Token }
 
        $response = Invoke-WebRequest $completeUrl -Method GET -Headers $headers -UseBasicParsing:$UseBasicUrlParsing @params
        $response.Content | ConvertFrom-Json | Select-Object -ExpandProperty data
    }
 
    end {}
}


 
function Write-KVSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultUrl,
        [Parameter(Mandatory=$true)]
        [string]$Token,
        [Parameter(Mandatory=$true)]
        [string]$KeyValueEnginePath,                
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
        [string]$SecretName,
        [Parameter(Mandatory=$true)]
        $SecretValue,
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "v1",
        [switch]$UseBasicUrlParsing
    )
 
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }
        
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
        
        [Net.ServicePointManager]::SecurityProtocol = 
            ([Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12)
    }
 
    process {
        $completeUrl = "$VaultUrl/$ApiVersion/$KeyValueEnginePath/data/$SecretName"
        $headers = @{ "X-Vault-Token" = $Token }
        $secretValueJson = ConvertTo-Json @{ data = $SecretValue } -Depth 16
 
        Invoke-WebRequest $completeUrl -Method POST -Headers $headers -Body $secretValueJson -UseBasicParsing:$UseBasicUrlParsing @params
    }
 
    end {}
}


 
#---------------------------------------
#----EXPORTS----------------------------
#---------------------------------------
Export-ModuleMember -Function Login-AppRole
Export-ModuleMember -Function Login-GCE
Export-ModuleMember -Function Read-KVSecret
Export-ModuleMember -Function Write-KVSecret